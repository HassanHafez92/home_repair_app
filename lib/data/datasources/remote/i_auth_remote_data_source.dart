// Auth remote data source interface.
//
// Defines the contract for authentication operations with Firebase Auth.
// Throws [AuthException] or [ServerException] on errors.

// Interface for remote authentication operations.
//
// Implementations should interact with Firebase Auth and throw appropriate
// exceptions from `core/error/exceptions.dart`.
abstract class IAuthRemoteDataSource {
  /// Stream of authentication state changes.
  ///
  /// Emits the current user's UID when authenticated, null when signed out.
  Stream<String?> get authStateChanges;

  /// The currently authenticated user's UID, if any.
  String? get currentUserId;

  /// Whether the current user's email is verified.
  bool get isEmailVerified;

  /// Signs up a new user with email and password.
  ///
  /// Returns a map containing the created user's data including:
  /// - `uid`: The Firebase user ID
  /// - `email`: The user's email
  /// - `emailVerified`: Whether email is verified
  ///
  /// Throws [AuthException] on authentication failures.
  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Signs in a user with email and password.
  ///
  /// Returns the user's UID on success.
  ///
  /// Throws [AuthException] on authentication failures.
  Future<String> signInWithEmail({
    required String email,
    required String password,
  });

  /// Signs in a user with their Google account.
  ///
  /// Returns a map containing user data on success, null if cancelled.
  ///
  /// Throws [AuthException] on authentication failures.
  Future<Map<String, dynamic>?> signInWithGoogle();

  /// Signs in a user with their Facebook account.
  ///
  /// Returns a map containing user data on success, null if cancelled.
  ///
  /// Throws [AuthException] on authentication failures.
  Future<Map<String, dynamic>?> signInWithFacebook();

  /// Signs out the current user from all authentication providers.
  ///
  /// Throws [AuthException] on failures.
  Future<void> signOut();

  /// Sends a password reset email.
  ///
  /// Throws [AuthException] on failures.
  Future<void> sendPasswordResetEmail(String email);

  /// Sends an email verification link to the current user.
  ///
  /// Throws [AuthException] on failures.
  Future<void> sendEmailVerification();

  /// Reloads the current user's data from Firebase.
  ///
  /// Throws [AuthException] on failures.
  Future<void> reloadUser();
}
