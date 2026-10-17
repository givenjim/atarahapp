import 'dart:convert';
import 'dart:io';

import 'package:atarah/core/app/app.dart';
import 'package:atarah/core/config/app_config.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/providers.dart';
import 'package:atarah/core/storage/token_store.dart';
import 'package:atarah/features/onboarding/device_services.dart';
import 'package:atarah/features/onboarding/onboarding_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// P1-M2 journeys on a real Android emulator against the real backend: a new member registers, verifies,
/// completes profile setup (saved on the server), is killed mid-way and resumes, and receives a Passport.
///
/// NOT RUN YET: the product owner runs emulator checks at the end of each phase (and on request), so this
/// file is written and analysed but has not been executed on a device.
///
///   flutter test integration_test/onboarding_journey_test.dart --flavor dev -d emulator-5554 \
///     --dart-define=ATARAH_API_BASE_URL=http://10.0.2.2:3000
const _mailpit = String.fromEnvironment(
  'ATARAH_MAILPIT_URL',
  defaultValue: 'http://10.0.2.2:58025',
);
const _password = 'Journey-pass-1';

/// The phone's location services and camera are not available to an automated run, so these are scripted;
/// everything else (API, database, media pipeline) is real.
class _ScriptedLocation implements LocationLookup {
  @override
  Future<List<String>> placeNames() async => ['Nairobi City County'];
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final stamp = DateTime.now().millisecondsSinceEpoch;
  final email = 'setup.$stamp@demo.atarah.test';

  Widget app() => ProviderScope(
    retry: noAutomaticRetry,
    overrides: [
      appConfigProvider.overrideWithValue(AppConfig.forFlavor(Flavor.dev)),
      locationLookupProvider.overrideWithValue(_ScriptedLocation()),
    ],
    child: const AtarahApp(),
  );

  Future<String> mailedCode() async {
    final client = HttpClient();
    try {
      for (var i = 0; i < 40; i++) {
        final listReq = await client.getUrl(
          Uri.parse('$_mailpit/api/v1/search?query=to:$email'),
        );
        final list = jsonDecode(
          await utf8.decoder.bind(await listReq.close()).join(),
        ) as Map<String, dynamic>;
        final messages = list['messages'] as List<dynamic>;
        if (messages.isNotEmpty) {
          final id = (messages.first as Map<String, dynamic>)['ID'] as String;
          final msgReq = await client.getUrl(
            Uri.parse('$_mailpit/api/v1/message/$id'),
          );
          final msg = jsonDecode(
            await utf8.decoder.bind(await msgReq.close()).join(),
          ) as Map<String, dynamic>;
          return RegExp(r'\b(\d{6})\b')
              .firstMatch(msg['Text'] as String)!
              .group(1)!;
        }
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
      throw StateError('No email arrived for $email');
    } finally {
      client.close();
    }
  }

  Future<void> settle(WidgetTester t, {int seconds = 2}) async {
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

  Future<void> tapLabel(WidgetTester t, String label, {int wait = 2}) async {
    final f = find.text(label).last;
    await t.ensureVisible(f);
    await t.tap(f);
    await settle(t, seconds: wait);
  }

  testWidgets(
    'register, set up the profile, restart mid-way, finish with a Passport',
    (t) async {
      await SecureTokenStore().clear();
      await t.pumpWidget(app());
      await settle(t);

      // Register and verify with the emailed code.
      await tapLabel(t, 'Create account');
      await t.enterText(find.byType(TextField).at(0), 'Setup Tester');
      await t.enterText(find.byType(TextField).at(1), email);
      await t.enterText(find.byType(TextField).at(2), _password);
      await t.tap(find.byType(AtCheckbox));
      await t.pump();
      await tapLabel(t, 'Continue', wait: 4);
      await t.enterText(find.byType(TextField).first, await mailedCode());
      await tapLabel(t, 'Verify', wait: 5);

      // Setup opens on the intro.
      expect(find.text("Let's set up your creative identity"), findsOneWidget);
      await tapLabel(t, 'Get started');

      // Discipline and specialisation.
      expect(find.text('What do you create?'), findsOneWidget);
      await tapLabel(t, 'Animation');
      await tapLabel(t, 'Continue');
      await tapLabel(t, '2D animation');
      await tapLabel(t, 'Character design');
      await tapLabel(t, 'Continue');

      // Skills, interests, areas.
      await tapLabel(t, 'After Effects');
      await tapLabel(t, 'Procreate');
      await tapLabel(t, 'Storyboarding');
      await tapLabel(t, 'Continue');

      // Location from the (scripted) phone lookup.
      expect(find.text('Where are you based?'), findsOneWidget);
      await tapLabel(t, 'Use my current location', wait: 3);
      expect(find.text('We set your county to Nairobi.'), findsOneWidget);
      await tapLabel(t, 'Continue');

      // "Kill the app" here: everything so far is on the server, so a fresh start resumes at the basics.
      expect(find.text('Introduce yourself'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      await t.pumpWidget(app());
      await settle(t, seconds: 4);
      expect(find.text('Introduce yourself'), findsOneWidget);
      expect(find.text('Step 5 of 6'), findsOneWidget);

      // The member is signed in, so no sign-in was needed. Fill the basics.
      await t.enterText(find.byType(TextField).at(0), 'Setup Tester');
      await t.enterText(find.byType(TextField).at(1), 'setup_$stamp');
      await t.enterText(
        find.byType(TextField).at(2),
        'Illustrator and 2D animator in Nairobi.',
      );
      await settle(t, seconds: 2);
      expect(find.textContaining('is available.'), findsOneWidget);
      await tapLabel(t, 'Continue');

      // The camera and gallery need a person, so the photo is skipped here.
      expect(find.text('Add a profile photo'), findsOneWidget);
      await tapLabel(t, 'Skip for now', wait: 4);

      // The Passport is real: county code from the member's county, and a number from the server.
      expect(find.text('Your creative journey starts here.'), findsOneWidget);
      expect(find.textContaining('ATR · NBI ·'), findsOneWidget);
      await tapLabel(t, 'Go to Home');
      expect(find.byType(AtTabBar), findsOneWidget);
    },
  );
}
