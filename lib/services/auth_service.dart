// File: lib/services/auth_service.dart
// Purpose: Handles all authentication related operations using Firebase Auth.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn? _googleSignIn;

  // Initialize GoogleSignIn instance
  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignIn == null) {
      final instance = GoogleSignIn.instance;
      // Note: In version 7.x, scopes are requested through authorizationClient
      await instance.initialize();
      _googleSignIn = instance;
    }
  }

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign Up with Email & Password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send verification email immediately after signup
      await sendEmailVerification();

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unknown error occurred during sign up.');
    }
  }

  // Sign In with Email & Password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unknown error occurred during sign in.');
    }
  }

  // Sign In with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Initialize GoogleSignIn if not already done
      await _ensureGoogleSignInInitialized();

      // Try lightweight authentication first
      GoogleSignInAccount? googleUser = await _googleSignIn!
          .attemptLightweightAuthentication();

      // If lightweight auth fails, use interactive authentication
      if (googleUser == null) {
        if (_googleSignIn!.supportsAuthenticate()) {
          googleUser = await _googleSignIn!.authenticate();
        } else {
          // Fallback for platforms that don't support authenticate()
          throw Exception(
            'Interactive sign-in not supported on this platform. Please use platform-specific UI.',
          );
        }
      }

      // Obtain the auth details from the request
      // Note: In version 7.x, authentication is a property, not a method
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential
      // Note: In version 7.x, only idToken is available (no accessToken)
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google [UserCredential]
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (kDebugMode) print('Google Sign In Error: $e');
      throw Exception('Google Sign In failed.');
    }
  }

  // Sign In with Facebook
  Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken;
        if (accessToken != null) {
          final OAuthCredential credential = FacebookAuthProvider.credential(
            accessToken.tokenString,
          );
          return await _auth.signInWithCredential(credential);
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (kDebugMode) print('Facebook Sign In Error: $e');
      throw Exception('Facebook Sign In failed.');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      final futures = <Future>[_auth.signOut(), FacebookAuth.instance.logOut()];

      // Only sign out from Google if it was initialized
      if (_googleSignIn != null) {
        futures.add(_googleSignIn!.signOut());
      }

      await Future.wait(futures);
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Email Verification - Send verification email
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Check if current user's email is verified
  bool get isEmailVerified {
    final user = _auth.currentUser;
    return user?.emailVerified ?? false;
  }

  // Reload user to get updated email verification status
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      if (kDebugMode) print('Error reloading user: $e');
    }
  }

  // Phone Authentication (Verification)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String, int?) onCodeSent,
    required Function(String) onCodeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
    );
  }

  // Helper to handle Firebase Auth Exceptions
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found for that email.');
      case 'wrong-password':
        return Exception('Wrong password provided for that user.');
      case 'email-already-in-use':
        return Exception('The account already exists for that email.');
      case 'weak-password':
        return Exception('The password provided is too weak.');
      case 'invalid-email':
        return Exception('The email address is not valid.');
      default:
        return Exception(e.message ?? 'An authentication error occurred.');
    }
  }
}
