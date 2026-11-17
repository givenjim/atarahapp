import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// The one Realtime subscription the app has (Master Prompt 5.7 rule 4): new rows in `public.notifications`.
/// Row Level Security (`userId = auth.uid()`) means only the signed-in member's own rows are ever delivered, so
/// no filter is needed (and a filter on the camelCase column would silently deliver nothing).
abstract interface class NotificationsRealtime {
  /// Calls [onInsert] for each new notification. Returns the function that unsubscribes.
  Future<void Function()> subscribe({required void Function() onInsert});
}

class SupabaseNotificationsRealtime implements NotificationsRealtime {
  SupabaseNotificationsRealtime(this._client);

  final SupabaseClient _client;

  @override
  Future<void Function()> subscribe({required void Function() onInsert}) async {
    void applyToken(String? token) {
      if (token != null) _client.realtime.setAuth(token);
    }

    applyToken(_client.auth.currentSession?.accessToken);
    final tokens = _client.auth.onAuthStateChange.listen(
      (s) => applyToken(s.session?.accessToken),
      onError: (Object _) {},
    );
    final channel = _client
        .channel('own-notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (_) => onInsert(),
        )
        .subscribe();
    return () {
      unawaited(tokens.cancel());
      unawaited(_client.removeChannel(channel));
    };
  }
}
