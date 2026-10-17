import '../storage/token_store.dart';

/// Exchanges a refresh token for a new token pair (the backend rotates the refresh token on every use).
typedef RefreshCall = Future<StoredTokens> Function(String refreshToken);

/// Refreshes the session at most once at a time. Many requests can hit 401 together when the access token
/// expires; they all wait for the same refresh, then retry with the new token. Without this, parallel
/// refreshes would replay a rotated refresh token and the backend would end the whole session.
class SessionRefresher {
  SessionRefresher({required this.store, required this.refreshCall});

  final TokenStore store;
  final RefreshCall refreshCall;

  Future<StoredTokens?>? _inFlight;
  int refreshCount = 0;

  /// [usedAccessToken] is the token the failed request was sent with. If the store already holds a newer
  /// one, another request refreshed in the meantime and no network call is needed.
  Future<StoredTokens?> refresh(String? usedAccessToken) {
    return _inFlight ??= _run(usedAccessToken)
        .whenComplete(() => _inFlight = null);
  }

  Future<StoredTokens?> _run(String? used) async {
    final current = await store.read();
    if (current == null) return null;
    if (used != null && current.accessToken != used) return current;
    try {
      refreshCount++;
      final next = await refreshCall(current.refreshToken);
      await store.write(next);
      return next;
    } catch (_) {
      return null;
    }
  }
}
