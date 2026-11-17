import 'package:atarah/core/realtime/notifications_realtime.dart';

/// Stand-in for the Supabase Realtime channel: tests call [emit] to deliver a new notification.
class FakeNotificationsRealtime implements NotificationsRealtime {
  void Function()? _onInsert;
  int subscriptions = 0;
  int unsubscriptions = 0;

  bool get isOpen => _onInsert != null;

  @override
  Future<void Function()> subscribe({required void Function() onInsert}) async {
    subscriptions++;
    _onInsert = onInsert;
    return () {
      unsubscriptions++;
      _onInsert = null;
    };
  }

  void emit() => _onInsert?.call();
}
