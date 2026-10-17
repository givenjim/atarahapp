import 'package:atarah/core/app/app.dart';
import 'package:atarah/core/config/app_config.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/providers.dart';
import 'package:atarah/core/storage/token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// P0-M7 journey on a real Android emulator against the real backend (no fakes):
///   splash -> welcome -> developer sign-in (real API) -> tab shell -> profile (real member) -> placeholders
///   -> restart restores the session from secure storage -> sign out.
///
/// Run (backend on :3000 with the dev demo seed, emulator running):
///   flutter test integration_test/app_journey_test.dart --flavor dev -d emulator-5554 \
///     --dart-define=ATARAH_API_BASE_URL=http://10.0.2.2:3000
// Defaults to the seeded demo member; pass another verified account to test a freshly registered one:
//   --dart-define=ATARAH_E2E_EMAIL=... --dart-define=ATARAH_E2E_PASSWORD=... --dart-define=ATARAH_E2E_NAME=...
const _email = String.fromEnvironment(
  'ATARAH_E2E_EMAIL',
  defaultValue: 'nia@demo.atarah.test',
);
const _password = String.fromEnvironment(
  'ATARAH_E2E_PASSWORD',
  defaultValue: 'Atarah-demo-1',
);
const _name = String.fromEnvironment(
  'ATARAH_E2E_NAME',
  defaultValue: 'Nia Wairimu',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget app() => ProviderScope(
    retry: noAutomaticRetry,
    overrides: [
      appConfigProvider.overrideWithValue(AppConfig.forFlavor(Flavor.dev)),
      // Real keystore-backed storage, real network: that is the point of this test.
    ],
    child: const AtarahApp(),
  );

  Future<void> settle(WidgetTester t, {int seconds = 8}) async {
    // The real network needs wall-clock time; pump until the expected widget appears or time runs out.
    final end = DateTime.now().add(Duration(seconds: seconds));
    while (DateTime.now().isBefore(end)) {
      await t.pump(const Duration(milliseconds: 250));
    }
    await t.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 10),
    );
  }

  testWidgets('member journey against the real API', (t) async {
    // Start clean: no leftover session from a previous run.
    await SecureTokenStore().clear();

    await t.pumpWidget(app());
    await settle(t, seconds: 3);

    // 1. Signed out: welcome screen.
    expect(
      find.text('One creative identity. Many connected possibilities.'),
      findsOneWidget,
    );
    expect(find.text('Create account'), findsOneWidget);

    // 2. A wrong password shows the server's own message and stays signed out.
    await t.tap(find.text('Developer sign in'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).at(0), _email);
    await t.enterText(find.byType(TextField).at(1), 'Wrong-password-1');
    await t.tap(find.text('Sign in').last);
    await settle(t, seconds: 4);
    expect(find.textContaining("doesn't match this account"), findsOneWidget);
    expect(find.byType(AtTabBar), findsNothing);

    // 3. The right password signs in against the real backend.
    await t.enterText(find.byType(TextField).at(1), _password);
    await t.tap(find.text('Sign in').last);
    await settle(t, seconds: 6);
    expect(find.byType(AtTabBar), findsOneWidget);

    // 4. Every tab renders; unbuilt ones are labelled placeholders.
    for (final tab in ['Explore', 'Community', 'Opportunities', 'Home']) {
      await t.tap(
        find.descendant(of: find.byType(AtTabBar), matching: find.text(tab)),
      );
      await t.pumpAndSettle();
      expect(find.text('Soon · P1'), findsOneWidget, reason: tab);
    }

    // 5. Profile shows the real member from /users/me.
    await t.tap(
      find.descendant(
        of: find.byType(AtTabBar),
        matching: find.text('Profile'),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text(_name), findsOneWidget);
    expect(find.text(_email), findsOneWidget);
    expect(find.text('Free plan'), findsOneWidget);

    // 6. A profile entry point opens a labelled placeholder with no tab bar, and back returns.
    await t.tap(find.text('Settings'));
    await t.pumpAndSettle();
    expect(find.text('Soon · P1'), findsOneWidget);
    expect(find.byType(AtTabBar), findsNothing);
    await t.tap(find.text('Go back'));
    await t.pumpAndSettle();
    expect(find.byType(AtTabBar), findsOneWidget);

    // 7. "Restart": a brand new app instance finds the stored session and goes straight to the shell.
    await t.pumpWidget(const SizedBox());
    await t.pumpWidget(app());
    await settle(t, seconds: 4);
    expect(
      find.byType(AtTabBar),
      findsOneWidget,
      reason: 'session restored from secure storage',
    );
    await t.tap(
      find.descendant(
        of: find.byType(AtTabBar),
        matching: find.text('Profile'),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text(_name), findsOneWidget);

    // 8. Sign out returns to welcome and clears the stored tokens.
    await t.ensureVisible(find.text('Sign out'));
    await t.tap(find.text('Sign out'));
    await settle(t, seconds: 3);
    expect(
      find.text('One creative identity. Many connected possibilities.'),
      findsOneWidget,
    );
    expect(await SecureTokenStore().read(), isNull);

    // 9. After sign-out a restart lands on welcome, not the shell.
    await t.pumpWidget(const SizedBox());
    await t.pumpWidget(app());
    await settle(t, seconds: 3);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.byType(AtTabBar), findsNothing);
  });
}
