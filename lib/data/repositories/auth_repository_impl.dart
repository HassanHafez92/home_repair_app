/// Auth repository implementation using Firebase Auth.
///
/// This implementation handles all Firebase Auth interactions and
/// returns Either types for Clean Architecture error handling.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';

/// Implementation of [IAuthRepository] using Firebase Auth.
class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  GoogleSignIn? _googleSignIn;

  AuthRepositoryImpl({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignIn == null) {
      final instance = GoogleSignIn.instance;
      await instance.initialize();
      _googleSignIn = instance;
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await _getUserEntity(user.uid);
    });
  }

  @override
  UserEntity? get currentUser {
    // This is synchronous, so we can't fetch from Firestore here
    // Return a minimal entity based on Firebase User
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      fullName: user.displayName ?? '',
      profilePhoto: user.photoURL,
      role: UserRole.customer, // Default, actual role retrieved async
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      updatedAt: DateTime.now(),
      lastActive: DateTime.now(),
      emailVerified: user.emailVerified,
    );
  }

  @override
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<UserEntity?> _getUserEntity(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      return _mapToUserEntity(uid, data);
    } catch (e) {
      debugPrint('Error fetching user entity: $e');
      return null;
    }
  }

  UserEntity _mapToUserEntity(String uid, Map<String, dynamic> data) {
    return UserEntity(
      id: uid,
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      fullName: data['fullName'] ?? '',
      profilePhoto: data['profilePhoto'],
      role: _parseRole(data['role']),
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      lastActive: _parseTimestamp(data['lastActive']),
      emailVerified: data['emailVerified'],
    );
  }

  UserRole _parseRole(dynamic role) {
    if (role == null) return UserRole.customer;
    if (role is String) {
      switch (role) {
        case 'admin':
          return UserRole.admin;
        case 'technician':
          return UserRole.technician;
        default:
          return UserRole.customer;
      }
    }
    return UserRole.customer;
  }

  DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.tryParse(timestamp) ?? DateTime.now();
    }
    return DateTime.now();
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Left(AuthFailure('Failed to create user account'));
      }

      final now = DateTime.now();
      final userData = {
        'id': credential.user!.uid,
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'role': 'customer',
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'lastActive': Timestamp.fromDate(now),
        'emailVerified': false,
        'savedAddresses': [],
        'savedPaymentMethods': [],
      };

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userData);

      // Send email verification
      await credential.user!.sendEmailVerification();

      return Right(
        UserEntity(
          id: credential.user!.uid,
          email: email,
          phoneNumber: phoneNumber,
          fullName: fullName,
          role: UserRole.customer,
          createdAt: now,
          updatedAt: now,
          lastActive: now,
          emailVerified: false,
        ),
      );
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e)));
    } catch (e) {
      return Left(AuthFailure('An error occurred during sign up: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Left(AuthFailure('Failed to sign in'));
      }

      final userEntity = await _getUserEntity(credential.user!.uid);
      if (userEntity == null) {
        return const Left(AuthFailure('User data not found'));
      }

      return Right(userEntity);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e)));
    } catch (e) {
      return Left(AuthFailure('An error occurred during sign in: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();
      GoogleSignInAccount? googleUser = await _googleSignIn!
          .attemptLightweightAuthentication();

      if (googleUser == null) {
        if (_googleSignIn!.supportsAuthenticate()) {
          googleUser = await _googleSignIn!.authenticate();
        } else {
          return const Left(
            AuthFailure('Interactive sign-in not supported on this platform'),
          );
        }
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user == null) {
        return const Right(null);
      }

      // Check if user exists in Firestore, if not create them
      final existingUser = await _getUserEntity(userCredential.user!.uid);
      if (existingUser != null) {
        return Right(existingUser);
      }

      // Create new user in Firestore
      final now = DateTime.now();
      final userData = {
        'id': userCredential.user!.uid,
        'email': userCredential.user!.email ?? '',
        'fullName': userCredential.user!.displayName ?? '',
        'profilePhoto': userCredential.user!.photoURL,
        'role': 'customer',
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'lastActive': Timestamp.fromDate(now),
        'emailVerified': userCredential.user!.emailVerified,
      };

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      return Right(_mapToUserEntity(userCredential.user!.uid, userData));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e)));
    } catch (e) {
      if (kDebugMode) print('Google Sign In Error: $e');
      return Left(AuthFailure('Google Sign In failed: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken;
        if (accessToken != null) {
          final OAuthCredential credential = FacebookAuthProvider.credential(
            accessToken.tokenString,
          );
          final userCredential = await _auth.signInWithCredential(credential);

          if (userCredential.user == null) {
            return const Right(null);
          }

          // Check if user exists in Firestore, if not create them
          final existingUser = await _getUserEntity(userCredential.user!.uid);
          if (existingUser != null) {
            return Right(existingUser);
          }

          // Create new user in Firestore
          final now = DateTime.now();
          final userData = {
            'id': userCredential.user!.uid,
            'email': userCredential.user!.email ?? '',
            'fullName': userCredential.user!.displayName ?? '',
            'profilePhoto': userCredential.user!.photoURL,
            'role': 'customer',
            'createdAt': Timestamp.fromDate(now),
            'updatedAt': Timestamp.fromDate(now),
            'lastActive': Timestamp.fromDate(now),
            'emailVerified': userCredential.user!.emailVerified,
          };

          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(userData);

          return Right(_mapToUserEntity(userCredential.user!.uid, userData));
        }
      }
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e)));
    } catch (e) {
      if (kDebugMode) print('Facebook Sign In Error: $e');
      return Left(AuthFailure('Facebook Sign In failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      final futures = <Future>[_auth.signOut(), FacebookAuth.instance.logOut()];
      if (_googleSignIn != null) {
        futures.add(_googleSignIn!.signOut());
      }
      await Future.wait(futures);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Error signing out: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e)));
    } catch (e) {
      return Left(AuthFailure('Error sending password reset email: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e)));
    } catch (e) {
      return Left(AuthFailure('Error sending email verification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
      return const Right(null);
    } catch (e) {
      if (kDebugMode) print('Error reloading user: $e');
      return Left(AuthFailure('Error reloading user: $e'));
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
