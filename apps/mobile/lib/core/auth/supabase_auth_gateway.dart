import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../storage/secure_storage.dart';
import 'auth_gateway.dart';
import 'identifier.dart';

/// Where the OAuth provider sends the member back to the app.
const oauthRedirectUrl = 'atarah://auth-callback';

/// Supabase Auth behind [AuthGateway]. This is the only place the app talks to Supabase Auth. The Supabase
/// client is used for authentication and for the single Realtime subscription; never for application data
/// (Master Prompt 5.7 rule 1).
class SupabaseAuthGateway implements AuthGateway {
  SupabaseAuthGateway(this._client) {
    _sub = _client.auth.onAuthStateChange.listen((state) {
      switch (state.event) {
        case AuthChangeEvent.signedOut:
          _signedOut.add(null);
        case AuthChangeEvent.signedIn:
          if (_oauthPending) {
            _oauthPending = false;
            _externalSignedIn.add(null);
          }
        default:
      }
    }, onError: (Object _) {});
  }

  final SupabaseClient _client;
  late final StreamSubscription<AuthState> _sub;
  final _signedOut = StreamController<void>.broadcast();
  final _externalSignedIn = StreamController<void>.broadcast();
  bool _oauthPending = false;

  GoTrueClient get _auth => _client.auth;

  @override
  bool get hasSession => _auth.currentSession != null;

  @override
  String? get accessToken => _auth.currentSession?.accessToken;

  @override
  Stream<void> get signedOut => _signedOut.stream;

  @override
  Stream<void> get externalSignedIn => _externalSignedIn.stream;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on AuthRetryableFetchException catch (e) {
      throw AuthGatewayException(
        code: 'network',
        message: e.message,
        network: true,
      );
    } on AuthWeakPasswordException catch (e) {
      throw AuthGatewayException(
        code: 'weak_password',
        message: e.message,
        statusCode: int.tryParse(e.statusCode ?? ''),
      );
    } on AuthException catch (e) {
      throw AuthGatewayException(
        code: e.code ?? 'unknown',
        message: e.message,
        statusCode: int.tryParse(e.statusCode ?? ''),
      );
    } on SocketException catch (e) {
      throw AuthGatewayException(
        code: 'network',
        message: e.message,
        network: true,
      );
    } on TimeoutException {
      throw const AuthGatewayException(
        code: 'network',
        network: true,
        timedOut: true,
      );
    }
  }

  @override
  Future<bool> signUp({
    required ParsedIdentifier identifier,
    required String password,
    required Map<String, Object?> metadata,
  }) => _guard(() async {
    final isEmail = identifier.kind == IdentifierKind.email;
    final res = await _auth.signUp(
      email: isEmail ? identifier.value : null,
      phone: isEmail ? null : identifier.value,
      password: password,
      data: {...metadata},
    );
    // With confirmation switched on, signing up an address that already has an account returns an obfuscated
    // user with no identities instead of an error.
    final identities = res.user?.identities;
    return identities != null && identities.isEmpty;
  });

  @override
  Future<void> verifySignupCode({
    required ParsedIdentifier identifier,
    required String code,
  }) => _guard(() async {
    final isEmail = identifier.kind == IdentifierKind.email;
    await _auth.verifyOTP(
      email: isEmail ? identifier.value : null,
      phone: isEmail ? null : identifier.value,
      token: code,
      type: isEmail ? OtpType.signup : OtpType.sms,
    );
  });

  @override
  Future<void> resendSignupCode(ParsedIdentifier identifier) =>
      _guard(() async {
        final isEmail = identifier.kind == IdentifierKind.email;
        await _auth.resend(
          email: isEmail ? identifier.value : null,
          phone: isEmail ? null : identifier.value,
          type: isEmail ? OtpType.signup : OtpType.sms,
        );
      });

  @override
  Future<void> signInWithPassword({
    required ParsedIdentifier identifier,
    required String password,
  }) => _guard(() async {
    final isEmail = identifier.kind == IdentifierKind.email;
    await _auth.signInWithPassword(
      email: isEmail ? identifier.value : null,
      phone: isEmail ? null : identifier.value,
      password: password,
    );
  });

  @override
  Future<void> sendRecoveryCode(ParsedIdentifier identifier) =>
      _guard(() async {
        if (identifier.kind == IdentifierKind.email) {
          await _auth.resetPasswordForEmail(identifier.value);
        } else {
          await _auth.signInWithOtp(
            phone: identifier.value,
            shouldCreateUser: false,
          );
        }
      });

  @override
  Future<void> verifyRecoveryCode({
    required ParsedIdentifier identifier,
    required String code,
  }) => _guard(() async {
    final isEmail = identifier.kind == IdentifierKind.email;
    await _auth.verifyOTP(
      email: isEmail ? identifier.value : null,
      phone: isEmail ? null : identifier.value,
      token: code,
      type: isEmail ? OtpType.recovery : OtpType.sms,
    );
  });

  @override
  Future<void> updatePassword(String newPassword) => _guard(() async {
    await _auth.updateUser(UserAttributes(password: newPassword));
  });

  @override
  Future<void> signOutOthers() =>
      _guard(() => _auth.signOut(scope: SignOutScope.others));

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on Object {
      // The session is removed locally first; the server copy expires on its own.
    }
  }

  @override
  Future<String?> refreshSession() async {
    try {
      final res = await _auth.refreshSession();
      return res.session?.accessToken;
    } on AuthSessionMissingException {
      return null;
    } on AuthRetryableFetchException catch (e) {
      throw AuthGatewayException(
        code: 'network',
        message: e.message,
        network: true,
      );
    } on AuthException {
      return null;
    }
  }

  @override
  Future<void> signInWithGoogle() => _guard(() async {
    _oauthPending = true;
    try {
      await _auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: oauthRedirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } on Object {
      _oauthPending = false;
      rethrow;
    }
  });

  Future<void> dispose() async {
    await _sub.cancel();
    await _signedOut.close();
    await _externalSignedIn.close();
  }
}

/// The Supabase session lives in the platform keystore, not in plain preferences.
class SecureSessionStorage extends LocalStorage {
  SecureSessionStorage(this._store);

  static const _key = 'atarah.supabase.session';
  final KeyValueStore _store;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() async => (await _store.read(_key)) != null;

  @override
  Future<String?> accessToken() => _store.read(_key);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _store.write(_key, persistSessionString);

  @override
  Future<void> removePersistedSession() => _store.delete(_key);
}

/// Keeps the PKCE code verifier (used by Google OAuth) in the keystore too.
class SecurePkceStorage extends GotrueAsyncStorage {
  const SecurePkceStorage(this._store);

  final KeyValueStore _store;

  @override
  Future<String?> getItem({required String key}) =>
      _store.read('atarah.pkce.$key');

  @override
  Future<void> setItem({required String key, required String value}) =>
      _store.write('atarah.pkce.$key', value);

  @override
  Future<void> removeItem({required String key}) =>
      _store.delete('atarah.pkce.$key');
}

/// Starts the Supabase SDK. Called once at start-up, before the first frame.
Future<SupabaseClient> initialiseSupabase({
  required String url,
  required String publishableKey,
  required KeyValueStore store,
}) async {
  await Supabase.initialize(
    url: url,
    publishableKey: publishableKey,
    authOptions: FlutterAuthClientOptions(
      localStorage: SecureSessionStorage(store),
      pkceAsyncStorage: SecurePkceStorage(store),
    ),
  );
  return Supabase.instance.client;
}
