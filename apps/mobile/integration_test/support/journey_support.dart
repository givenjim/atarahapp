import 'dart:convert';
import 'dart:io';

import 'package:atarah/core/app/app.dart';
import 'package:atarah/core/auth/supabase_auth_gateway.dart';
import 'package:atarah/core/config/app_config.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/providers.dart';
import 'package:atarah/core/routing/app_router.dart';
import 'package:atarah/core/storage/secure_storage.dart';
import 'package:atarah/features/onboarding/device_services.dart';
import 'package:atarah/features/onboarding/onboarding_providers.dart';
import 'package:atarah/features/profile/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

/// Shared plumbing for the P1-M12 end-to-end journeys. They run on a real Android emulator against the real
/// local backend and the local Supabase stack (no fakes; only the phone's location sensor is scripted, because a
/// script cannot answer an OS permission dialog). Verification codes are read from the local Mailpit inbox, as a
/// person would read their email.
///
///   flutter test integration_test/journey_NAME_test.dart --flavor dev -d emulator-5554 \
///     --dart-define-from-file=env.dev.json   (run `adb reverse tcp:55321 tcp:55321` first; see apps/mobile/README.md)
///
/// Light and dark: the journeys follow the account's appearance setting; run each twice, the second time after
/// choosing Dark in Settings > Appearance (see docs/DEVELOPMENT.md).
const mailpitUrl = String.fromEnvironment(
  'ATARAH_MAILPIT_URL',
  defaultValue: 'http://10.0.2.2:55324',
);
const journeyPassword = 'Journey-pass-1';

/// The dev demo password (see `apps/backend/prisma/seed/demo.ts`; development only).
const demoPassword = 'Atarah-demo-1';

class _ScriptedLocation implements LocationLookup {
  @override
  Future<List<String>> placeNames() async => ['Nairobi City County'];
}

class JourneyEnv {
  JourneyEnv._(this.supabase);
  final SupabaseClient supabase;

  /// Addresses the app tried to open outside Atarah. Nothing is launched, so the run stays in the app.
  final List<Uri> opened = [];

  static Future<JourneyEnv> start() async {
    final config = AppConfig.forFlavor(Flavor.dev);
    final supabase = await initialiseSupabase(
      url: config.supabaseUrl,
      publishableKey: config.supabasePublishableKey,
      store: SecureKeyValueStore(),
    );
    return JourneyEnv._(supabase);
  }

  Widget app() => ProviderScope(
    retry: noAutomaticRetry,
    overrides: [
      appConfigProvider.overrideWithValue(AppConfig.forFlavor(Flavor.dev)),
      supabaseClientProvider.overrideWithValue(supabase),
      locationLookupProvider.overrideWithValue(_ScriptedLocation()),
      openLinkProvider.overrideWithValue((uri) async {
        opened.add(uri);
        return true;
      }),
    ],
    child: const AtarahApp(),
  );

  /// Newest 6-digit code mailed to [email] (waits for it to arrive).
  Future<String> mailedCode(String email) async {
    final client = HttpClient();
    try {
      for (var i = 0; i < 40; i++) {
        final listReq = await client.getUrl(
          Uri.parse('$mailpitUrl/api/v1/search?query=to:$email'),
        );
        final list = jsonDecode(
          await utf8.decoder.bind(await listReq.close()).join(),
        ) as Map<String, dynamic>;
        final messages = list['messages'] as List<dynamic>;
        if (messages.isNotEmpty) {
          final id = (messages.first as Map<String, dynamic>)['ID'] as String;
          final msgReq = await client.getUrl(
            Uri.parse('$mailpitUrl/api/v1/message/$id'),
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
}

/// Lets the app run for [seconds] (network, animations), then settles.
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

/// Opens an app path through the real router (as a deep link would).
Future<void> goTo(WidgetTester t, String path, {int wait = 3}) async {
  final container = ProviderScope.containerOf(
    t.element(find.byType(AtarahApp)),
  );
  container.read(appRouterProvider).go(path);
  await settle(t, seconds: wait);
}

/// Scrolls the first scrollable until [finder] is on screen.
Future<void> reveal(WidgetTester t, Finder finder) => t.scrollUntilVisible(
  finder,
  300,
  scrollable: find.byType(Scrollable).first,
);

/// Starts the app signed out.
Future<void> startSignedOut(WidgetTester t, JourneyEnv env) async {
  await env.supabase.auth.signOut();
  await t.pumpWidget(const SizedBox());
  await t.pumpWidget(env.app());
  await settle(t);
}

/// Registers a new member through the UI, verifies with the mailed code and completes profile setup. Leaves the
/// app on Home.
Future<void> registerAndSetUp(
  WidgetTester t,
  JourneyEnv env, {
  required String email,
  required String name,
  required String handle,
}) async {
  await startSignedOut(t, env);
  await tapLabel(t, 'Create account');
  await t.enterText(find.byType(TextField).at(0), name);
  await t.enterText(find.byType(TextField).at(1), email);
  await t.enterText(find.byType(TextField).at(2), journeyPassword);
  await t.tap(find.byType(AtCheckbox));
  await t.pump();
  await tapLabel(t, 'Continue', wait: 4);
  expect(find.text('Verify your email'), findsOneWidget);
  await t.enterText(find.byType(TextField).first, await env.mailedCode(email));
  await tapLabel(t, 'Verify', wait: 5);

  expect(find.text("Let's set up your creative identity"), findsOneWidget);
  await tapLabel(t, 'Get started');
  await tapLabel(t, 'Animation');
  await tapLabel(t, 'Continue');
  await tapLabel(t, '2D animation');
  await tapLabel(t, 'Continue');
  await tapLabel(t, 'After Effects');
  await tapLabel(t, 'Continue');
  await tapLabel(t, 'Use my current location', wait: 3);
  await tapLabel(t, 'Continue');
  await t.enterText(find.byType(TextField).at(0), name);
  await t.enterText(find.byType(TextField).at(1), handle);
  await t.enterText(
    find.byType(TextField).at(2),
    'Illustrator and 2D animator in Nairobi.',
  );
  await settle(t, seconds: 2);
  await tapLabel(t, 'Continue');
  await tapLabel(t, 'Skip for now', wait: 4);
  await tapLabel(t, 'Go to Home');
  expect(find.byType(AtTabBar), findsOneWidget);
}

/// Signs in an existing account through the UI.
Future<void> signIn(
  WidgetTester t,
  JourneyEnv env, {
  required String email,
  required String password,
}) async {
  await startSignedOut(t, env);
  await tapLabel(t, 'Sign in');
  await t.enterText(find.byType(TextField).at(0), email);
  await t.enterText(find.byType(TextField).at(1), password);
  await tapLabel(t, 'Sign in', wait: 5);
}
