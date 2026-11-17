import 'package:atarah/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/journey_support.dart';

/// P1-M12 journey (e) on a real emulator against the real local backend (dev demo seed): a privacy change by
/// one account is visible to another account; then the account is deleted. NOT RUN: no emulator was available
/// when this was written. Fake-backed twin that does run: `test/journeys/settings_journey_test.dart`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late final JourneyEnv env;
  setUpAll(() async => env = await JourneyEnv.start());

  final stamp = DateTime.now().millisecondsSinceEpoch;
  final email = 'privacy.$stamp@demo.atarah.test';
  final handle = 'priv_$stamp';
  const viewer = 'kiptoo@demo.atarah.test';

  testWidgets('privacy change, then another account sees it', (t) async {
    await registerAndSetUp(
      t,
      env,
      email: email,
      name: 'Privacy Tester',
      handle: handle,
    );

    // Location starts visible to members (the setup default).
    // Another account (a demo member) opens the profile and sees the location.
    await signIn(t, env, email: viewer, password: demoPassword);
    await goTo(t, Routes.creativePath(handle), wait: 4);
    expect(find.text('Privacy Tester'), findsWidgets);
    expect(find.text('Nairobi, Kenya'), findsOneWidget);

    // The owner hides it; the other account no longer sees it.
    await signIn(t, env, email: email, password: journeyPassword);
    await goTo(t, Routes.privacySettings);
    // The second row is Location (the first is Contact details, already "Only me").
    await t.tap(find.text('Only me').at(1));
    await settle(t, seconds: 3);
    await signIn(t, env, email: viewer, password: demoPassword);
    await goTo(t, Routes.creativePath(handle), wait: 4);
    expect(find.text('Nairobi, Kenya'), findsNothing);
  });

  testWidgets('delete account: confirm with DELETE, scheduled, signed out', (
    t,
  ) async {
    await signIn(t, env, email: email, password: journeyPassword);
    await goTo(t, Routes.deleteAccount);
    await t.enterText(find.byType(TextField).first, 'DELETE');
    await t.pump();
    await tapLabel(t, 'Delete account permanently', wait: 5);
    expect(find.text('Your account is scheduled for deletion'), findsOneWidget);
    await tapLabel(t, 'OK', wait: 4);
    expect(find.text('Sign in'), findsWidgets);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
