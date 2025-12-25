// Auth remote data source implementation using Firebase Auth.
//
// Handles all Firebase Auth interactions, throwing exceptions on errors.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/error/exceptions.dart';
import 'i_auth_remote_data_source.dart';

/// Implementation of [IAuthRemoteDataSource] using Firebase Auth.
class AuthRemoteDataSource implements IAuthRemoteDataSource {
  final FirebaseAuth _auth;
  GoogleSignIn? _googleSignIn;

  AuthRemoteDataSource({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignIn == null) {
      final instance = GoogleSignIn.instance;
      await instance.initialize(
        serverClientId:
            '970866219192-se866npaf4oh34t2cpumold0v306uu8v.apps.googleusercontent.com',
      );
      _googleSignIn = instance;
    }
  }

  @override
  Stream<String?> get authStateChanges {
    return _auth.authStateChanges().map((user) => user?.uid);
  }

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  @override
  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException('Failed to create user account');
      }

      // Send email verification
      await credential.user!.sendEmailVerification();

      return {
        'uid': credential.user!.uid,
        'email': credential.user!.email ?? email,
        'emailVerified': credential.user!.emailVerified,
        'creationTime': credential.user!.metadata.creationTime,
      };
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e), e.code);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Sign up failed: $e');
    }
  }

  @override
  Future<String> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException('Failed to sign in');
      }

      return credential.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e), e.code);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Sign in failed: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();
      GoogleSignInAccount? googleUser = await _googleSignIn!
          .attemptLightweightAuthentication();

      if (googleUser == null) {
        if (_googleSignIn!.supportsAuthenticate()) {
          googleUser = await _googleSignIn!.authenticate();
        } else {
          throw const AuthException(
            'Interactive sign-in not supported on this platform',
          );
        }
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user == null) {
        return null;
      }

      return {
        'uid': userCredential.user!.uid,
        'email': userCredential.user!.email ?? '',
        'displayName': userCredential.user!.displayName ?? '',
        'photoURL': userCredential.user!.photoURL,
        'emailVerified': userCredential.user!.emailVerified,
        'isNewUser': userCredential.additionalUserInfo?.isNewUser ?? false,
      };
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e), e.code);
    } catch (e) {
      if (e is AuthException) rethrow;
      if (kDebugMode) print('Google Sign In Error: $e');
      throw AuthException('Google Sign In failed: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> signInWithFacebook() async {
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
            return null;
          }

          return {
            'uid': userCredential.user!.uid,
            'email': userCredential.user!.email ?? '',
            'displayName': userCredential.user!.displayName ?? '',
            'photoURL': userCredential.user!.photoURL,
            'emailVerified': userCredential.user!.emailVerified,
            'isNewUser': userCredential.additionalUserInfo?.isNewUser ?? false,
          };
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e), e.code);
    } catch (e) {
      if (e is AuthException) rethrow;
      if (kDebugMode) print('Facebook Sign In Error: $e');
      throw AuthException('Facebook Sign In failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final futures = <Future>[_auth.signOut(), FacebookAuth.instance.logOut()];
      if (_googleSignIn != null) {
        futures.add(_googleSignIn!.signOut());
      }
      await Future.wait(futures);
    } catch (e) {
      throw AuthException('Error signing out: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e), e.code);
    } catch (e) {
      throw AuthException('Error sending password reset email: $e');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e), e.code);
    } catch (e) {
      throw AuthException('Error sending email verification: $e');
    }
  }

  @override
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      if (kDebugMode) print('Error reloading user: $e');
      throw AuthException('Error reloading user: $e');
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
