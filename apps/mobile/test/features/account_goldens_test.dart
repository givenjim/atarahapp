import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/fake_account.dart';
import '../support/fakes.dart';

/// Activity, notifications, saved, settings home, privacy, the delete screen and membership, in both appearances,
/// 390x844 at 1x. Regenerate after intentional visual changes:
/// `flutter test --update-goldens test/features/account_goldens_test.dart`.
void main() {
  for (final appearance in AtAppearance.values) {
    final dark = appearance == AtAppearance.dark;

    Future<Harness> open(WidgetTester t, String at) async {
      final h = Harness(
        appearance: appearance,
        auth: FakeAuthRepository(
          restored: fakeUser(
            name: 'Nia Wairimu',
            appearance: dark ? MeDtoAppearance.dark : MeDtoAppearance.light,
          ),
        ),
        notifications: FakeNotificationsRepository(
          items: [
            notif(
              id: 'n-1',
              title: 'New connection request',
              body: 'Amani Otieno wants to connect with you.',
            ),
            notif(
              id: 'n-2',
              title: 'One week left',
              body: 'Emerging Creatives Grant 2027 closes in 7 days.',
              category: NotificationCategory.opportunities,
              ago: const Duration(hours: 3),
            ),
            notif(
              id: 'n-3',
              title: 'Certificate earned',
              body: 'You completed Build a Portfolio That Gets You Hired.',
              category: NotificationCategory.learning,
              read: true,
              group: NotificationItemDtoGroup.earlier,
              ago: const Duration(days: 2),
            ),
          ],
        ),
        saved: FakeSavedRepository(
          items: [
            savedItem(),
            savedItem(
              type: SavedKind.learning,
              id: 'c-1',
              title: 'Build a Portfolio That Gets You Hired',
              subtitle: 'Course · Portfolio Building',
              path: '/learning/courses/c-1',
            ),
            savedItem(
              type: SavedKind.article,
              id: 'a-1',
              title: 'Pricing for illustrators',
              subtitle: 'Atarah Editorial',
              path: '/articles/pricing',
            ),
          ],
        ),
      );
      await h.pump(t);
      h.router.go(at);
      await t.pumpAndSettle();
      return h;
    }

    Future<void> shoot(WidgetTester t, String name) => expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/screens/$name.${appearance.name}.png'),
    );

    testWidgets('activity ${appearance.name}', (t) async {
      await open(t, '/activity');
      await shoot(t, 'activity');
    });

    testWidgets('notifications ${appearance.name}', (t) async {
      await open(t, '/notifications');
      await shoot(t, 'notifications');
    });

    testWidgets('saved ${appearance.name}', (t) async {
      await open(t, '/saved');
      await shoot(t, 'saved');
    });

    testWidgets('settings home ${appearance.name}', (t) async {
      await open(t, '/settings');
      await shoot(t, 'settings_home');
    });

    testWidgets('privacy ${appearance.name}', (t) async {
      await open(t, '/settings/privacy');
      await shoot(t, 'settings_privacy');
    });

    testWidgets('delete account ${appearance.name}', (t) async {
      await open(t, '/settings/delete');
      await shoot(t, 'settings_delete');
    });

    testWidgets('membership ${appearance.name}', (t) async {
      await open(t, '/settings/membership');
      await shoot(t, 'settings_membership');
    });
  }
}
