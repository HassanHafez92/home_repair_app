// File: lib/services/auth_service.dart
// Purpose: Handles all authentication related operations using Firebase Auth.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

/// Service class that handles all Firebase Authentication operations.
///
/// This service provides methods for:
/// - Email/password authentication (sign up, sign in)
/// - Social authentication (Google, Facebook)
/// - Password management (reset, update)
/// - Email verification
/// - Phone number verification
///
/// ## Usage Example
///
/// ```dart
/// final authService = AuthService();
///
/// // Sign up a new user
/// try {
///   final credential = await authService.signUpWithEmail(
///     email: 'user@example.com',
///     password: 'securePassword123',
///   );
///   print('User signed up: ${credential.user?.email}');
/// } catch (e) {
///   print('Sign up failed: $e');
/// }
/// ```
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  /// Initializes the GoogleSignIn instance if not already initialized.
  ///
  /// This is called automatically before any Google Sign-In operation.
  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      // Initialize GoogleSignIn with Web Client ID for Android
      await _googleSignIn.initialize(
        serverClientId:
            '970866219192-se866npaf4oh34t2cpumold0v306uu8v.apps.googleusercontent.com',
      );
      _isGoogleSignInInitialized = true;
    }
  }

  /// Stream of authentication state changes.
  ///
  /// Emits the current [User] when the auth state changes (sign in/out).
  /// Returns `null` when no user is signed in.
  ///
  /// Use this to listen for authentication changes in the app:
  ///
  /// ```dart
  /// authService.authStateChanges.listen((user) {
  ///   if (user != null) {
  ///     print('User signed in: ${user.email}');
  ///   } else {
  ///     print('User signed out');
  ///   }
  /// });
  /// ```
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Returns the currently signed-in user, or `null` if no user is signed in.
  User? get currentUser => _auth.currentUser;

  /// Creates a new user account with email and password.
  ///
  /// After successful registration, a verification email is automatically sent
  /// to the user's email address.
  ///
  /// **Parameters:**
  /// - [email]: The user's email address. Must be a valid email format.
  /// - [password]: The user's password. Must meet Firebase password requirements
  ///   (at least 6 characters).
  ///
  /// **Returns:** A [UserCredential] containing the newly created user.
  ///
  /// **Throws:**
  /// - [Exception] with message 'The account already exists for that email.'
  ///   if the email is already registered.
  /// - [Exception] with message 'The password provided is too weak.'
  ///   if the password doesn't meet requirements.
  /// - [Exception] with message 'The email address is not valid.'
  ///   if the email format is invalid.
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

  /// Signs in a user with email and password.
  ///
  /// **Parameters:**
  /// - [email]: The user's registered email address.
  /// - [password]: The user's password.
  ///
  /// **Returns:** A [UserCredential] containing the signed-in user.
  ///
  /// **Throws:**
  /// - [Exception] with message 'No user found for that email.'
  ///   if no account exists with the given email.
  /// - [Exception] with message 'Wrong password provided for that user.'
  ///   if the password is incorrect.
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

  /// Signs in a user using their Google account.
  ///
  /// This method first attempts lightweight (silent) authentication.
  /// If that fails, it shows the interactive Google Sign-In dialog.
  ///
  /// **Returns:** A [UserCredential] on success, or `null` if sign-in was cancelled.
  ///
  /// **Throws:** [Exception] with message 'Google Sign In failed.' on error.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Initialize GoogleSignIn if not already done
      await _ensureGoogleSignInInitialized();

      // Try lightweight authentication first
      GoogleSignInAccount? googleUser = await _googleSignIn
          .attemptLightweightAuthentication();

      // If lightweight auth fails, use interactive authentication
      googleUser ??= await _googleSignIn.authenticate();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential
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

  /// Signs in a user using their Facebook account.
  ///
  /// Shows the Facebook login dialog and authenticates with Firebase.
  ///
  /// **Returns:** A [UserCredential] on success, or `null` if sign-in was
  /// cancelled or the access token was not available.
  ///
  /// **Throws:** [Exception] with message 'Facebook Sign In failed.' on error.
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

  /// Signs out the current user from all authentication providers.
  ///
  /// This signs out from Firebase Auth, Facebook, and Google (if initialized).
  ///
  /// **Throws:** [Exception] if sign out fails.
  Future<void> signOut() async {
    try {
      final futures = <Future>[_auth.signOut(), FacebookAuth.instance.logOut()];

      // Only sign out from Google if it was initialized
      if (_isGoogleSignInInitialized) {
        futures.add(_googleSignIn.signOut());
      }

      await Future.wait(futures);
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  /// Sends a password reset email to the specified email address.
  ///
  /// **Parameters:**
  /// - [email]: The email address to send the reset link to.
  ///
  /// **Throws:** [Exception] if the email is not registered or invalid.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sends an email verification link to the current user's email.
  ///
  /// Does nothing if no user is logged in or if email is already verified.
  ///
  /// **Throws:** [Exception] if sending verification email fails.
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

  /// Returns `true` if the current user's email is verified.
  ///
  /// Returns `false` if no user is logged in or email is not verified.
  bool get isEmailVerified {
    final user = _auth.currentUser;
    return user?.emailVerified ?? false;
  }

  /// Reloads the current user's data from Firebase.
  ///
  /// Call this to refresh the user's email verification status.
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      if (kDebugMode) print('Error reloading user: $e');
    }
  }

  /// Initiates phone number verification.
  ///
  /// **Parameters:**
  /// - [phoneNumber]: The phone number to verify in E.164 format (e.g., +1234567890).
  /// - [onVerificationCompleted]: Called when verification completes automatically.
  /// - [onVerificationFailed]: Called when verification fails.
  /// - [onCodeSent]: Called when verification code is sent. Provides verification ID.
  /// - [onCodeAutoRetrievalTimeout]: Called when auto-retrieval times out.
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

  /// Updates the current user's password.
  ///
  /// Requires the user to provide their current password for re-authentication.
  ///
  /// **Parameters:**
  /// - [currentPassword]: The user's current password for verification.
  /// - [newPassword]: The new password to set.
  ///
  /// **Throws:**
  /// - [Exception] with 'No user logged in' if no user is authenticated.
  /// - [Exception] with 'Wrong password' if current password is incorrect.
  /// - [Exception] with 'Weak password' if new password doesn't meet requirements.
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user logged in');
      }

      // Reauthenticate user before changing password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  /// Updates the current user's email address.
  ///
  /// Requires the user to provide their current password for re-authentication.
  /// A verification email will be sent to the new address.
  ///
  /// **Parameters:**
  /// - [currentPassword]: The user's current password for verification.
  /// - [newEmail]: The new email address to set.
  ///
  /// **Throws:**
  /// - [Exception] with 'No user logged in' if no user is authenticated.
  /// - [Exception] with 'Wrong password' if current password is incorrect.
  /// - [Exception] with 'Email already in use' if new email is registered.
  Future<void> updateEmail({
    required String currentPassword,
    required String newEmail,
  }) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user logged in');
      }

      // Reauthenticate user before changing email
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Send verification to new email before updating
      await user.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to update email: $e');
    }
  }

  /// Converts Firebase Auth exceptions to user-friendly error messages.
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
