import 'package:flutter/foundation.dart';

import '../api/generated/export.dart';
import '../networking/failures.dart';
import '../storage/token_store.dart';

/// The result of asking for a verification or recovery code.
class CodeTicket {
  const CodeTicket({required this.resendAvailableAt, this.destination});

  /// Masked destination from the server (for example `n***@gmail.com`), when it sent one.
  final String? destination;

  /// When the member may ask for another code (the server's 60-second cooldown).
  final DateTime? resendAvailableAt;
}

/// Talks to the auth endpoints through the generated client and keeps the token store in step.
/// Widgets never call this directly; they go through [SessionController] and feature notifiers.
class AuthRepository {
  AuthRepository({required this._api, required this._store});

  final AtarahApiClient _api;
  final TokenStore _store;

  LoginDtoClient get _client => switch (defaultTargetPlatform) {
    TargetPlatform.iOS => LoginDtoClient.ios,
    _ => LoginDtoClient.android,
  };

  /// The signed-in member if the stored tokens are still good, otherwise null (and the tokens are cleared).
  /// Network problems are rethrown: being offline at launch is not the same as being signed out.
  Future<MeDto?> restoreSession() async {
    final tokens = await _store.read();
    if (tokens == null) return null;
    try {
      return (await _api.users.currentUser()).data;
    } on Object catch (e) {
      final failure = mapError(e);
      if (failure is NetworkFailure) throw failure;
      if (failure is ApiFailure &&
          (failure.statusCode == 401 || failure.statusCode == 403)) {
        await _store.clear();
        return null;
      }
      throw failure;
    }
  }

  Future<MeDto> signIn({
    required String identifier,
    required String password,
  }) async {
    try {
      final res = await _api.auth.login(
        body: LoginDto(
          identifier: identifier.trim(),
          password: password,
          client: _client,
          deviceName: '${defaultTargetPlatform.name} app',
        ),
      );
      await _store.write(
        StoredTokens(
          accessToken: res.data.accessToken,
          refreshToken: res.data.refreshToken,
        ),
      );
      return res.data.user;
    } on Object catch (e) {
      throw mapError(e);
    }
  }

  /// Creates the account and sends the first verification code. The account stays unverified, and no tokens
  /// are issued, until [verify] succeeds.
  Future<CodeTicket> register({
    required String fullName,
    required String identifier,
    required String password,
  }) async {
    try {
      final res = await _api.auth.register(
        body: RegisterDto(
          fullName: fullName.trim(),
          identifier: identifier.trim(),
          password: password,
          consent: const ConsentDto(terms: true, privacy: true),
          client: RegisterDtoClient.values.byName(_client.name),
        ),
      );
      final v = res.data.verification;
      return CodeTicket(
        destination: v.destination,
        resendAvailableAt: v.resendAvailableAt,
      );
    } on Object catch (e) {
      throw mapError(e);
    }
  }

  /// Confirms the code, which signs the member in.
  Future<MeDto> verify({
    required String identifier,
    required String code,
  }) async {
    try {
      final res = await _api.auth.verify(
        body: VerifyDto(
          identifier: identifier.trim(),
          code: code,
          client: VerifyDtoClient.values.byName(_client.name),
        ),
      );
      await _store.write(
        StoredTokens(
          accessToken: res.data.accessToken,
          refreshToken: res.data.refreshToken,
        ),
      );
      return res.data.user;
    } on Object catch (e) {
      throw mapError(e);
    }
  }

  Future<DateTime?> resendCode(String identifier) async {
    try {
      final res = await _api.auth.resend(
        body: IdentifierDto(identifier: identifier.trim()),
      );
      return res.data.resendAvailableAt;
    } on Object catch (e) {
      throw mapError(e);
    }
  }

  /// Asks for a password recovery code. The API answers the same way for unknown accounts.
  Future<void> requestPasswordReset(String identifier) async {
    try {
      await _api.auth.forgot(
        body: IdentifierDto(identifier: identifier.trim()),
      );
    } on Object catch (e) {
      throw mapError(e);
    }
  }

  /// Sets the new password. The API signs the account out everywhere else; the caller signs in afterwards.
  Future<void> resetPassword({
    required String identifier,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _api.auth.reset(
        body: ResetPasswordDto(
          identifier: identifier.trim(),
          code: code,
          newPassword: newPassword,
        ),
      );
    } on Object catch (e) {
      throw mapError(e);
    }
  }

  /// Ends the session on the server (best effort) and always clears local tokens.
  Future<void> signOut() async {
    try {
      await _api.auth.logout();
    } on Object {
      // The server session expires on its own; the device must still be signed out.
    } finally {
      await _store.clear();
    }
  }

  Future<void> clearLocalSession() => _store.clear();
}
