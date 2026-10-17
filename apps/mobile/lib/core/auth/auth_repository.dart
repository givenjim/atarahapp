import 'package:flutter/foundation.dart';

import '../api/generated/export.dart';
import '../networking/failures.dart';
import '../storage/token_store.dart';

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
