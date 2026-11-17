import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/auth/session_controller.dart';
import '../../core/providers.dart';
import 'discover_providers.dart';

part 'unread_notifications.g.dart';

/// The live unread-notification count for the Home bell.
///
/// It starts from what `GET /home` reports and goes up by one for each new row the member's own
/// `notifications` Realtime channel delivers (Master Prompt 5.7 rule 4). The channel is opened once after
/// sign-in and closed on sign-out. The notifications screen (P1-M11) keeps it in step through [set] and [decrement].
@Riverpod(keepAlive: true)
class UnreadNotifications extends _$UnreadNotifications {
  @override
  int build() {
    final signedIn = ref.watch(sessionStatusProvider) == SessionStatus.signedIn;
    if (!signedIn) return 0;

    // The server's count is the truth whenever Home loads it.
    ref.listen(homeFeedProvider, (_, next) {
      final home = next.value;
      if (home != null) state = home.unreadNotifications.toInt();
    });

    var closed = false;
    void Function()? unsubscribe;
    ref
        .read(notificationsRealtimeProvider)
        .subscribe(onInsert: () => state = state + 1)
        .then(
          (cancel) => closed ? cancel() : unsubscribe = cancel,
          // Live updates are a nicety: without them the count refreshes with Home.
          onError: (Object _) {},
        );
    ref.onDispose(() {
      closed = true;
      unsubscribe?.call();
    });

    return ref.read(homeFeedProvider).value?.unreadNotifications.toInt() ?? 0;
  }

  /// The notifications screen reports what the server says (after a refresh or "mark all read").
  void set(int count) => state = count < 0 ? 0 : count;

  /// A notification was opened: one fewer unread.
  void decrement() => state = state > 0 ? state - 1 : 0;
}
