import 'dart:convert';
import 'dart:io';

import 'package:atarah/core/app/app.dart';
import 'package:atarah/core/config/app_config.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/providers.dart';
import 'package:atarah/core/storage/token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// P1-M1 journeys on a real Android emulator against the real backend (no fakes). Verification and recovery
/// codes are read from the local Mailpit inbox, exactly as a person would read their email.
///
///   flutter test integration_test/auth_journeys_test.dart --flavor dev -d emulator-5554 \
///     --dart-define=ATARAH_API_BASE_URL=http://10.0.2.2:3000
const _mailpit = String.fromEnvironment(
  'ATARAH_MAILPIT_URL',
  defaultValue: 'http://10.0.2.2:58025',
);

const _password = 'Journey-pass-1';
const _newPassword = 'Journey-new-2';
const _wrongPasswordBanner =
    "That password doesn't match this account. Check it and try again, or reset it.";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final stamp = DateTime.now().millisecondsSinceEpoch;
  final email = 'journey.$stamp@demo.atarah.test';
  const name = 'Journey Tester';

  Widget app() => ProviderScope(
    retry: noAutomaticRetry,
    overrides: [
      appConfigProvider.overrideWithValue(AppConfig.forFlavor(Flavor.dev)),
    ],
    child: const AtarahApp(),
  );

  /// Newest 6-digit code mailed to [email] after [after] earlier messages.
  Future<String> mailedCode(int after) async {
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
        if (messages.length > after) {
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

  Future<int> mailCount() async {
    final client = HttpClient();
    try {
      final req = await client.getUrl(
        Uri.parse('$_mailpit/api/v1/search?query=to:$email'),
      );
      final body = jsonDecode(
        await utf8.decoder.bind(await req.close()).join(),
      ) as Map<String, dynamic>;
      return (body['messages'] as List<dynamic>).length;
    } finally {
      client.close();
    }
  }

  Future<void> settle(WidgetTester t, {int seconds = 3}) async {
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

  Future<void> fresh(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pumpWidget(app());
    await settle(t);
  }

  Future<void> enterCode(WidgetTester t, String code) async {
    await t.enterText(find.byType(TextField).first, code);
    await t.pump();
  }

  testWidgets('1. register, verify by email code, land on onboarding entry', (
    t,
  ) async {
    await SecureTokenStore().clear();
    await t.pumpWidget(app());
    await settle(t);

    expect(
      find.text('One creative identity. Many connected possibilities.'),
      findsOneWidget,
    );
    await tapLabel(t, 'Create account');

    // Client-side checks first: an empty form sends nothing.
    await tapLabel(t, 'Continue', wait: 1);
    expect(find.text('Enter your full name.'), findsOneWidget);

    await t.enterText(find.byType(TextField).at(0), name);
    await t.enterText(find.byType(TextField).at(1), email);
    await t.enterText(find.byType(TextField).at(2), _password);
    await t.tap(find.byType(AtCheckbox));
    await t.pump();
    final before = await mailCount();
    await tapLabel(t, 'Continue', wait: 4);

    expect(find.text('Verify your email'), findsOneWidget);
    expect(find.text(email), findsOneWidget);
    expect(find.textContaining('Resend in'), findsOneWidget);

    // A wrong code is refused with the server's message.
    await enterCode(t, '000000');
    await tapLabel(t, 'Verify', wait: 3);
    expect(find.text('That code is not right or has expired.'), findsOneWidget);

    await enterCode(t, await mailedCode(before));
    await tapLabel(t, 'Verify', wait: 5);

    // New member: onboarding entry (built in P1-M2), then Home.
    expect(find.text('Creative profile setup'), findsOneWidget);
    expect(find.text('Soon · P1'), findsOneWidget);
    await tapLabel(t, 'Go back');
    expect(find.byType(AtTabBar), findsOneWidget);
    await t.tap(
      find.descendant(
        of: find.byType(AtTabBar),
        matching: find.text('Profile'),
      ),
    );
    await settle(t);
    expect(find.text(name), findsOneWidget);
    expect(find.text(email), findsOneWidget);
    await t.ensureVisible(find.text('Sign out'));
    await t.tap(find.text('Sign out'));
    await settle(t);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('2. sign in fails with the banner, then succeeds', (t) async {
    await SecureTokenStore().clear();
    await fresh(t);
    await tapLabel(t, 'Sign in');
    await t.enterText(find.byType(TextField).at(0), email);
    await t.enterText(find.byType(TextField).at(1), 'Wrong-pass-9');
    await tapLabel(t, 'Sign in', wait: 4);
    expect(find.text(_wrongPasswordBanner), findsOneWidget);
    expect(find.byType(AtTabBar), findsNothing);

    await t.enterText(find.byType(TextField).at(1), _password);
    await tapLabel(t, 'Sign in', wait: 5);
    expect(find.byType(AtTabBar), findsOneWidget);

    await t.tap(
      find.descendant(
        of: find.byType(AtTabBar),
        matching: find.text('Profile'),
      ),
    );
    await settle(t);
    await t.ensureVisible(find.text('Sign out'));
    await t.tap(find.text('Sign out'));
    await settle(t);
  });

  testWidgets('3. forgot password, reset, and sign in with the new password', (
    t,
  ) async {
    await SecureTokenStore().clear();
    await fresh(t);
    await tapLabel(t, 'Sign in');
    await tapLabel(t, 'Forgot password?');
    await t.enterText(find.byType(TextField).first, email);
    final before = await mailCount();
    await tapLabel(t, 'Send code', wait: 4);

    expect(find.text('Set a new password'), findsOneWidget);
    expect(find.text('Code sent. It expires in 15 minutes.'), findsOneWidget);

    await t.enterText(find.byType(TextField).at(0), await mailedCode(before));
    await t.enterText(find.byType(TextField).at(1), _newPassword);
    await t.enterText(find.byType(TextField).at(2), _newPassword);
    await tapLabel(t, 'Reset password', wait: 3);

    expect(find.byType(AtTabBar), findsOneWidget);
    expect(
      find.text('Password updated. You were signed out of your other devices.'),
      findsOneWidget,
    );

    // The old password no longer works; the new one does.
    await t.tap(
      find.descendant(
        of: find.byType(AtTabBar),
        matching: find.text('Profile'),
      ),
    );
    await settle(t);
    await t.ensureVisible(find.text('Sign out'));
    await t.tap(find.text('Sign out'));
    await settle(t);
    await tapLabel(t, 'Sign in');
    await t.enterText(find.byType(TextField).at(0), email);
    await t.enterText(find.byType(TextField).at(1), _password);
    await tapLabel(t, 'Sign in', wait: 4);
    expect(find.text(_wrongPasswordBanner), findsOneWidget);
    await t.enterText(find.byType(TextField).at(1), _newPassword);
    await tapLabel(t, 'Sign in', wait: 5);
    expect(find.byType(AtTabBar), findsOneWidget);
  });
}
