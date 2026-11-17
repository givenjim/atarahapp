import 'identifier.dart';

/// A failure from the authentication provider, stripped of any SDK type so the rest of the app (and the tests)
/// never depend on it. [code] is the provider's stable error code (for example `invalid_credentials`).
class AuthGatewayException implements Exception {
  const AuthGatewayException({
    required this.code,
    this.message = '',
    this.statusCode,
    this.network = false,
    this.timedOut = false,
  });

  final String code;
  final String message;
  final int? statusCode;

  /// The provider could not be reached.
  final bool network;
  final bool timedOut;

  @override
  String toString() => 'AuthGatewayException($code, $statusCode, $message)';
}

/// What the app needs from Supabase Auth (and nothing else: the Supabase client is never used for data).
/// The real implementation is `SupabaseAuthGateway`; tests use a fake.
abstract interface class AuthGateway {
  /// A session is held locally (it may still be rejected by the server).
  bool get hasSession;

  String? get accessToken;

  /// The provider ended the session (refresh failed, revoked elsewhere) or [signOut] ran.
  Stream<void> get signedOut;

  /// A session arrived from outside a form (Google OAuth coming back through the deep link).
  Stream<void> get externalSignedIn;

  /// Returns true when an account for this identifier already exists (the provider does not raise an error).
  Future<bool> signUp({
    required ParsedIdentifier identifier,
    required String password,
    required Map<String, Object?> metadata,
  });

  Future<void> verifySignupCode({
    required ParsedIdentifier identifier,
    required String code,
  });

  Future<void> resendSignupCode(ParsedIdentifier identifier);

  Future<void> signInWithPassword({
    required ParsedIdentifier identifier,
    required String password,
  });

  Future<void> sendRecoveryCode(ParsedIdentifier identifier);

  /// Checks the recovery code; on success the provider holds a session so the password can be changed.
  Future<void> verifyRecoveryCode({
    required ParsedIdentifier identifier,
    required String code,
  });

  Future<void> updatePassword(String newPassword);

  /// Ends every other session of the account, keeping this one.
  Future<void> signOutOthers();

  Future<void> signOut();

  /// A fresh access token, or null when the session cannot be refreshed (it is over).
  /// Throws [AuthGatewayException] with `network: true` when the provider cannot be reached.
  Future<String?> refreshSession();

  Future<void> signInWithGoogle();
}
