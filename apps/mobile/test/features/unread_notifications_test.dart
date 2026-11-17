import 'package:atarah/core/auth/session_controller.dart';
import 'package:atarah/features/discover/unread_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/fakes.dart';

void main() {
  group('live unread count (Realtime)', () {
    testWidgets('one channel is opened after sign-in and counts new rows', (
      t,
    ) async {
      final h = Harness(auth: FakeAuthRepository(restored: fakeUser()));
      await h.pump(t);
      expect(h.realtime.subscriptions, 1);
      final before = h.container.read(unreadNotificationsProvider);

      h.realtime.emit();
      h.realtime.emit();
      expect(h.container.read(unreadNotificationsProvider), before + 2);
    });

    testWidgets(
      'nothing is subscribed while signed out; sign-in opens it and sign-out closes it',
      (t) async {
        final h = Harness();
        await h.pump(t);
        expect(h.realtime.subscriptions, 0);

        await h.container
            .read(sessionControllerProvider.notifier)
            .signIn(identifier: 'a@b.co', password: 'Passw0rd-1');
        await t.pumpAndSettle();
        expect(h.realtime.subscriptions, 1);
        expect(h.realtime.isOpen, isTrue);
        expect(h.auth.deviceRegistrations, 1);

        await h.container.read(sessionControllerProvider.notifier).signOut();
        await t.pumpAndSettle();
        expect(h.realtime.isOpen, isFalse);
        expect(h.realtime.unsubscriptions, 1);
        expect(h.container.read(unreadNotificationsProvider), 0);
      },
    );
  });
}
