import '../api/generated/export.dart';
import '../device/device_registrar.dart';
import '../networking/failures.dart';
import 'auth_gateway.dart';
import 'identifier.dart';

/// The result of asking for a verification or recovery code.
class CodeTicket {
  const CodeTicket({required this.resendAvailableAt, this.destination});

  /// Where the code went, when known.
  final String? destination;

  /// When the member may ask for another code (the 60-second cooldown).
  final DateTime? resendAvailableAt;
}

/// The legal versions the member agrees to when signing up, taken from the published legal documents.
typedef LegalVersions = ({String terms, String privacy});

/// The 60-second wait between codes (Supabase Auth's rate limit, mirrored in the countdown).
const resendCooldown = Duration(seconds: 60);

/// Messages the sign-in, code and reset screens show. They are the same sentences the screens always showed.
abstract final class AuthMessages {
  static const wrongPassword =
      "That password doesn't match this account. Check it and try again, or reset it.";
  static const wrongCode = 'That code is not right or has expired.';
  static const verifyRequired = 'Verify your account to continue.';
  static const codeCooldown =
      'Please wait a moment before asking for another code.';
  static const signInLocked =
      'Too many sign-in attempts. Please wait a few minutes or reset your password.';
  static const deliveryFailed =
      'We could not send your code. Please tap resend in a moment.';
  static const suspended =
      'This account is suspended. Contact support if you think this is a mistake.';
  static const unusable = 'This account cannot be used right now.';
  static const samePassword =
      'Choose a password you have not used on this account before.';
  static String exists(IdentifierKind kind) =>
      'An account with this ${kind == IdentifierKind.email ? 'email' : 'phone number'} already exists. Sign in instead?';
  static String existsField(IdentifierKind kind) =>
      'An account with this ${kind == IdentifierKind.email ? 'email' : 'phone number'} already exists.';
}

enum _Op { signUp, verify, resend, signIn, recoverySend, reset }

/// Authentication for the app: Supabase Auth through [AuthGateway], plus `GET /users/me` for the member.
/// Provider errors are translated into the same [ApiFailure] shapes the screens already handle (reasons such as
/// `ACCOUNT_EXISTS` and `ACCOUNT_NOT_VERIFIED`, field errors, rate limits). Widgets never call this directly;
/// they go through `SessionController` and the feature notifiers.
class AuthRepository {
  AuthRepository({
    required this._gateway,
    required this._api,
    required this._legalVersions,
    required this._devices,
  });

  final AuthGateway _gateway;
  final AtarahApiClient _api;
  final Future<LegalVersions> Function() _legalVersions;
  final DeviceRegistrar _devices;

  /// The provider ended the session (refresh failed or it was revoked).
  Stream<void> get sessionEnded => _gateway.signedOut;

  /// A session arrived through the Google OAuth deep link.
  Stream<void> get externalSignedIn => _gateway.externalSignedIn;

  /// The signed-in member if the stored session is still good, otherwise null (and the session is cleared).
  /// Network problems are rethrown: being offline at launch is not the same as being signed out.
  Future<MeDto?> restoreSession() async {
    if (!_gateway.hasSession) return null;
    try {
      return await _currentMember();
    } on ApiFailure catch (f) {
      if (f.statusCode == 401 || f.statusCode == 403) {
        await _gateway.signOut();
        return null;
      }
      rethrow;
    }
  }

  Future<MeDto> _currentMember() async {
    try {
      return (await _api.users.currentUser()).data;
    } on Object catch (e) {
      throw mapError(e);
    }
  }

  /// Loads the member after a session was established; an account the API refuses (suspended, deactivated)
  /// is signed out again so no half-signed-in state remains.
  Future<MeDto> _enter() async {
    try {
      return await _currentMember();
    } on ApiFailure {
      await _gateway.signOut();
      rethrow;
    }
  }

  Future<MeDto> signIn({
    required String identifier,
    required String password,
  }) async {
    final id = parseIdentifier(identifier);
    try {
      await _gateway.signInWithPassword(identifier: id, password: password);
    } on AuthGatewayException catch (e) {
      if (e.code == 'email_not_confirmed' || e.code == 'phone_not_confirmed') {
        // Right password, account not verified yet: send a fresh code (the cooldown may refuse; the code
        // already sent still works) and take the member to the code screen.
        try {
          await _gateway.resendSignupCode(id);
        } on AuthGatewayException {
          // A recent code is still valid.
        }
      }
      throw _map(e, _Op.signIn, id);
    }
    return _enter();
  }

  /// Creates the account and sends the first verification code. The account stays unverified, and there is no
  /// session, until [verify] succeeds.
  Future<CodeTicket> register({
    required String fullName,
    required String identifier,
    required String password,
  }) async {
    final id = parseIdentifier(identifier);
    final LegalVersions legal;
    try {
      legal = await _legalVersions();
    } on Object catch (e) {
      throw mapError(e);
    }
    final bool exists;
    try {
      exists = await _gateway.signUp(
        identifier: id,
        password: password,
        metadata: {
          'full_name': fullName.trim(),
          'terms_version': legal.terms,
          'privacy_version': legal.privacy,
        },
      );
    } on AuthGatewayException catch (e) {
      throw _map(e, _Op.signUp, id);
    }
    if (exists) throw _accountExists(id.kind);
    return CodeTicket(
      destination: id.value,
      resendAvailableAt: DateTime.now().add(resendCooldown),
    );
  }

  /// Confirms the code, which signs the member in.
  Future<MeDto> verify({
    required String identifier,
    required String code,
  }) async {
    final id = parseIdentifier(identifier);
    try {
      await _gateway.verifySignupCode(identifier: id, code: code);
    } on AuthGatewayException catch (e) {
      throw _map(e, _Op.verify, id);
    }
    return _enter();
  }

  Future<DateTime?> resendCode(String identifier) async {
    final id = parseIdentifier(identifier);
    try {
      await _gateway.resendSignupCode(id);
    } on AuthGatewayException catch (e) {
      throw _map(e, _Op.resend, id);
    }
    return DateTime.now().add(resendCooldown);
  }

  /// Asks for a password recovery code. Unknown accounts look exactly like known ones, and a recent code that
  /// is still valid is not an error.
  Future<void> requestPasswordReset(String identifier) async {
    final id = parseIdentifier(identifier);
    try {
      await _gateway.sendRecoveryCode(id);
    } on AuthGatewayException catch (e) {
      if (_isRateLimit(e)) return;
      throw _map(e, _Op.recoverySend, id);
    }
  }

  /// Checks the recovery code, sets the new password and ends the account's other sessions. The code signs
  /// this device in, so the member is returned signed in.
  Future<MeDto> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  }) async {
    final id = parseIdentifier(identifier);
    try {
      await _gateway.verifyRecoveryCode(identifier: id, code: code);
    } on AuthGatewayException catch (e) {
      throw _map(e, _Op.reset, id);
    }
    try {
      await _gateway.updatePassword(newPassword);
    } on AuthGatewayException catch (e) {
      // The code is spent. Do not leave a session behind that the app does not know about.
      await _gateway.signOut();
      throw _map(e, _Op.reset, id, passwordStep: true);
    }
    try {
      await _gateway.signOutOthers();
    } on AuthGatewayException {
      // Best effort: the password has changed, and sessions can be ended from Security.
    }
    return _enter();
  }

  /// Ends the session (best effort on the server) and always clears it on the device.
  Future<void> signOut() => _gateway.signOut();

  Future<void> clearLocalSession() => _gateway.signOut();

  /// Starts Google sign-in in the browser. The session comes back through [externalSignedIn].
  Future<void> startGoogleSignIn() async {
    try {
      await _gateway.signInWithGoogle();
    } on AuthGatewayException catch (e) {
      throw _map(
        e,
        _Op.signIn,
        const ParsedIdentifier(IdentifierKind.email, ''),
      );
    }
  }

  /// The member after a session arrived from outside the forms (Google).
  Future<MeDto> enterWithExistingSession() => _enter();

  /// Tells the API about this install. Never throws.
  Future<void> registerDevice() async {
    await _devices.register();
  }

  // ---------------------------------------------------------------------------------------------------------

  bool _isRateLimit(AuthGatewayException e) =>
      e.statusCode == 429 ||
      e.code == 'over_email_send_rate_limit' ||
      e.code == 'over_sms_send_rate_limit' ||
      e.code == 'over_request_rate_limit';

  ApiFailure _accountExists(IdentifierKind kind) => ApiFailure(
    code: 'CONFLICT',
    message: AuthMessages.exists(kind),
    statusCode: 409,
    details: {
      'reason': 'ACCOUNT_EXISTS',
      'fields': [
        {
          'field': 'identifier',
          'messages': [AuthMessages.existsField(kind)],
        },
      ],
    },
  );

  AppFailure _map(
    AuthGatewayException e,
    _Op op,
    ParsedIdentifier id, {
    bool passwordStep = false,
  }) {
    if (e.network) return NetworkFailure(timedOut: e.timedOut);

    ApiFailure validation(String field, String message, {String? reason}) =>
        ApiFailure(
          code: 'VALIDATION_ERROR',
          message: message,
          statusCode: 422,
          details: {
            'fields': [
              {
                'field': field,
                'messages': [message],
              },
            ],
            'reason': ?reason,
          },
        );

    switch (e.code) {
      case 'user_already_exists':
      case 'email_exists':
      case 'phone_exists':
        return _accountExists(id.kind);
      case 'invalid_credentials':
        return const ApiFailure(
          code: 'INVALID_CREDENTIALS',
          message: AuthMessages.wrongPassword,
          statusCode: 401,
        );
      case 'email_not_confirmed':
      case 'phone_not_confirmed':
        return ApiFailure(
          code: 'VERIFICATION_REQUIRED',
          message: AuthMessages.verifyRequired,
          statusCode: 403,
          details: {'reason': 'ACCOUNT_NOT_VERIFIED', 'destination': id.value},
        );
      case 'user_banned':
        return const ApiFailure(
          code: 'FORBIDDEN',
          message: AuthMessages.suspended,
          statusCode: 403,
          details: {'reason': 'ACCOUNT_SUSPENDED'},
        );
      case 'weak_password':
        return validation(
          passwordStep || op == _Op.reset ? 'newPassword' : 'password',
          'Use at least 8 characters, including a letter and a number.',
          reason: 'WEAK_PASSWORD',
        );
      case 'same_password':
        return validation('newPassword', AuthMessages.samePassword);
      case 'otp_expired':
      case 'otp_disabled':
        return validation('code', AuthMessages.wrongCode);
      case 'sms_send_failed':
        return const ApiFailure(
          code: 'EXTERNAL_SERVICE_ERROR',
          message: AuthMessages.deliveryFailed,
          statusCode: 502,
          details: {'reason': 'CODE_DELIVERY_FAILED'},
        );
    }

    if (_isRateLimit(e)) {
      return ApiFailure(
        code: 'RATE_LIMITED',
        message: op == _Op.signIn
            ? AuthMessages.signInLocked
            : AuthMessages.codeCooldown,
        statusCode: 429,
        details: {
          'retryAfterSeconds': resendCooldown.inSeconds,
          if (op == _Op.signIn) 'reason': 'SIGN_IN_LOCKED',
        },
      );
    }
    if (op == _Op.verify || (op == _Op.reset && !passwordStep)) {
      // A malformed or unknown code is reported by the provider with a 4xx status.
      if (e.statusCode == 400 || e.statusCode == 403 || e.statusCode == 422) {
        return validation('code', AuthMessages.wrongCode);
      }
    }
    if ((op == _Op.signUp || op == _Op.resend || op == _Op.recoverySend) &&
        (e.statusCode ?? 500) >= 500) {
      return ApiFailure(
        code: 'EXTERNAL_SERVICE_ERROR',
        message: AuthMessages.deliveryFailed,
        statusCode: 502,
        details: {
          'reason': 'CODE_DELIVERY_FAILED',
          'accountCreated': op == _Op.signUp,
        },
      );
    }
    return UnexpectedFailure(e);
  }
}
