import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/appearance/appearance_controller.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/providers.dart';
import 'package:atarah/core/storage/secure_storage.dart';
import 'package:atarah/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/fakes.dart';
import '../support/pump_app.dart';

void main() {
  group('settings', () {
    testWidgets('opens from the profile screen and shows the groups', (
      t,
    ) async {
      final h = Harness(auth: FakeAuthRepository(restored: fakeUser()));
      await h.pump(t);
      h.router.go('/profile');
      await t.pumpAndSettle();
      await tapText(t, 'Settings');
      expect(h.path, '/settings');
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
    });

    testWidgets('the Appearance row switches the whole app to dark and back', (
      t,
    ) async {
      final h = Harness(auth: FakeAuthRepository(restored: fakeUser()));
      await h.pump(t);
      h.router.go('/settings');
      await t.pumpAndSettle();
      Brightness brightness() =>
          Theme.of(t.element(find.byType(SettingsScreen))).brightness;
      expect(brightness(), Brightness.light);

      await tapText(t, 'Appearance');
      expect(find.text('Dark'), findsOneWidget);
      expect(brightness(), Brightness.dark);

      await tapText(t, 'Appearance');
      expect(find.text('Light'), findsOneWidget);
      expect(brightness(), Brightness.light);
    });

    testWidgets('the other rows open real screens, not placeholders', (
      t,
    ) async {
      final h = Harness(auth: FakeAuthRepository(restored: fakeUser()));
      await h.pump(t);
      h.router.go('/settings');
      await t.pumpAndSettle();
      for (final (label, path) in [
        ('Privacy & visibility', '/settings/privacy'),
        ('Notifications', '/settings/notifications'),
        ('Membership', '/settings/membership'),
        ('Security', '/settings/security'),
        ('Help', '/settings/help'),
        ('Legal', '/settings/legal'),
      ]) {
        await tapText(t, label);
        expect(h.path, path, reason: label);
        expect(find.text('Soon · P1'), findsNothing, reason: label);
        h.router.pop();
        await t.pumpAndSettle();
        expect(find.text('Appearance'), findsOneWidget, reason: label);
      }
    });

    testWidgets('Sign out and Delete account are on the screen', (t) async {
      final h = Harness(auth: FakeAuthRepository(restored: fakeUser()));
      await h.pump(t);
      h.router.go('/settings');
      await t.pumpAndSettle();
      await t.scrollUntilVisible(find.text('Delete account'), 200);
      await tapText(t, 'Delete account');
      expect(h.path, '/settings/delete');
    });
  });

  group('settings golden', () {
    for (final appearance in AtAppearance.values) {
      testWidgets('settings screen, ${appearance.name}', (t) async {
        t.view.physicalSize = const Size(390, 844);
        t.view.devicePixelRatio = 1.0;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        await t.pumpWidget(
          ProviderScope(
            retry: noAutomaticRetry,
            overrides: [
              keyValueStoreProvider.overrideWithValue(MemoryKeyValueStore()),
              initialAppearanceProvider.overrideWithValue(appearance),
              authRepositoryProvider.overrideWithValue(
                FakeAuthRepository(
                  restored: fakeUser(
                    appearance: appearance == AtAppearance.dark
                        ? MeDtoAppearance.dark
                        : MeDtoAppearance.light,
                  ),
                ),
              ),
            ],
            child: atApp(
              const SettingsScreen(),
              scaffold: false,
              appearance: appearance,
            ),
          ),
        );
        await t.pumpAndSettle();
        await expectLater(
          find.byType(SettingsScreen),
          matchesGoldenFile('goldens/settings.${appearance.name}.png'),
        );
      });
    }
  });
}
