import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/fake_onboarding.dart';
import '../support/fakes.dart';

ApiFailure api(
  String code,
  String message, {
  int status = 400,
  Map<String, Object?> details = const {},
}) => ApiFailure(
  code: code,
  message: message,
  statusCode: status,
  details: details,
);

ApiFailure fieldFailure(String field, String message) => api(
  'VALIDATION_ERROR',
  'Check the highlighted fields.',
  details: {
    'fields': [
      {
        'field': field,
        'messages': [message],
      },
    ],
  },
);

Future<Harness> start(
  WidgetTester t, {
  FakeAuthRepository? auth,
  FakeContentRepository? content,
  FakeOnboardingRepository? onboarding,
  String? at,
}) async {
  final h = Harness(auth: auth, content: content, onboarding: onboarding);
  await h.pump(t);
  if (at != null) {
    h.router.go(at);
    await t.pumpAndSettle();
  }
  return h;
}

void main() {
  group('welcome', () {
    testWidgets('headline, pillars and the two ways in; no invented numbers', (
      t,
    ) async {
      await start(t);
      expect(
        find.text('One creative identity. Many connected possibilities.'),
        findsOneWidget,
      );
      for (final pillar in ['Identity', 'Learn', 'Connect', 'Earn']) {
        expect(find.text(pillar), findsOneWidget, reason: pillar);
      }
      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.textContaining('creatives'), findsNothing);
    });

    testWidgets('Terms and Privacy open the draft text, labelled as draft', (
      t,
    ) async {
      await start(t);
      await tapText(t, 'Terms');
      expect(find.text('DRAFT — Terms of Service'), findsOneWidget);
      expect(find.textContaining('has not been reviewed'), findsOneWidget);
      expect(find.text('Placeholder legal text for TERMS.'), findsOneWidget);
      await t.tap(find.bySemanticsLabel('Back'));
      await t.pumpAndSettle();
      await tapText(t, 'Privacy');
      expect(find.text('Placeholder legal text for PRIVACY.'), findsOneWidget);
    });

    testWidgets('a legal document that cannot load offers a retry', (t) async {
      final content = FakeContentRepository(
        legalFailure: const NetworkFailure(),
      );
      await start(t, content: content);
      await tapText(t, 'Terms');
      expect(find.text("We couldn't load this document."), findsOneWidget);
      content.legalFailure = null;
      await tapText(t, 'Try again');
      expect(find.text('Placeholder legal text for TERMS.'), findsOneWidget);
    });
  });

  group('sign up', () {
    testWidgets('empty submit shows every field error and sends nothing', (
      t,
    ) async {
      final h = await start(t, at: '/signup');
      await tapText(t, 'Continue');
      expect(find.text('Enter your full name.'), findsOneWidget);
      expect(
        find.text('Enter a valid email address or phone number.'),
        findsOneWidget,
      );
      expect(
        find.text('Use at least 8 characters, including a number.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'You need to accept the Terms and Privacy Policy to continue.',
        ),
        findsOneWidget,
      );
      expect(h.auth.calls.where((c) => c.startsWith('register')), isEmpty);
    });

    testWidgets('strength meter follows the password rule', (t) async {
      await start(t, at: '/signup');
      await typeInto(t, 2, 'abc');
      expect(find.textContaining('Weak'), findsOneWidget);
      await typeInto(t, 2, 'abcdefgh');
      expect(find.textContaining('Almost'), findsOneWidget);
      await typeInto(t, 2, 'abcdefg1');
      expect(find.text('Strong — 8+ characters with a number'), findsOneWidget);
    });

    testWidgets('password show and hide', (t) async {
      await start(t, at: '/signup');
      TextField field() => t.widget<TextField>(find.byType(TextField).at(2));
      expect(field().obscureText, isTrue);
      await t.tap(find.bySemanticsLabel('Show password'));
      await t.pump();
      expect(field().obscureText, isFalse);
    });

    testWidgets('a Kenyan phone number is sent as E.164 and verified by SMS', (
      t,
    ) async {
      final h = await start(t, at: '/signup');
      await typeInto(t, 0, 'Nia Wairimu');
      await typeInto(t, 1, '0712 345 678');
      await typeInto(t, 2, 'Passw0rd-1');
      await t.tap(find.byType(AtCheckbox));
      await t.pump();
      await tapText(t, 'Continue');
      expect(h.auth.calls, contains('register:+254712345678'));
      expect(h.path, '/verify');
      expect(find.text('Verify your phone number'), findsOneWidget);
      expect(find.text('+254712345678'), findsOneWidget);
    });

    testWidgets('success goes to verify with the countdown from the server', (
      t,
    ) async {
      final h = await start(t, at: '/signup');
      await typeInto(t, 0, 'Nia Wairimu');
      await typeInto(t, 1, 'Nia@Example.COM');
      await typeInto(t, 2, 'Passw0rd-1');
      await t.tap(find.byType(AtCheckbox));
      await t.pump();
      await tapText(t, 'Continue');
      expect(h.auth.calls, contains('register:nia@example.com'));
      expect(find.text('Verify your email'), findsOneWidget);
      expect(find.text('nia@example.com'), findsOneWidget);
      expect(find.textContaining('Resend in 0:4'), findsOneWidget);
      expect(h.events, ['user_registered']);
    });

    testWidgets('an existing account is explained and offers sign in', (
      t,
    ) async {
      final auth = FakeAuthRepository(
        registerFailure: api(
          'CONFLICT',
          'An account with this email already exists. Sign in instead?',
          status: 409,
          details: {'reason': 'ACCOUNT_EXISTS'},
        ),
      );
      await start(t, auth: auth, at: '/signup');
      await typeInto(t, 0, 'Nia Wairimu');
      await typeInto(t, 1, 'nia@example.com');
      await typeInto(t, 2, 'Passw0rd-1');
      await t.tap(find.byType(AtCheckbox));
      await t.pump();
      await tapText(t, 'Continue');
      expect(
        find.text(
          'An account with this email already exists. Sign in instead?',
        ),
        findsOneWidget,
      );
      await tapText(t, 'Sign in instead');
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('server field errors appear under their fields', (t) async {
      final auth = FakeAuthRepository(
        registerFailure: fieldFailure('password', 'Pick something longer.'),
      );
      await start(t, auth: auth, at: '/signup');
      await typeInto(t, 0, 'Nia Wairimu');
      await typeInto(t, 1, 'nia@example.com');
      await typeInto(t, 2, 'Passw0rd-1');
      await t.tap(find.byType(AtCheckbox));
      await t.pump();
      await tapText(t, 'Continue');
      expect(find.text('Pick something longer.'), findsOneWidget);
    });

    testWidgets('offline shows the connection message', (t) async {
      final auth = FakeAuthRepository(registerFailure: const NetworkFailure());
      await start(t, auth: auth, at: '/signup');
      await typeInto(t, 0, 'Nia Wairimu');
      await typeInto(t, 1, 'nia@example.com');
      await typeInto(t, 2, 'Passw0rd-1');
      await t.tap(find.byType(AtCheckbox));
      await t.pump();
      await tapText(t, 'Continue');
      expect(find.textContaining("You're offline"), findsOneWidget);
    });

    testWidgets('Continue with Google appears only when the flag is on', (
      t,
    ) async {
      await start(t, at: '/signup');
      expect(find.text('Continue with Google'), findsNothing);
    });

    testWidgets('Continue with Google is shown when the server enables it', (
      t,
    ) async {
      await start(
        t,
        content: FakeContentRepository(google: true),
        at: '/signup',
      );
      await t.ensureVisible(find.text('Continue with Google'));
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('the terms links open the legal text', (t) async {
      await start(t, at: '/signup');
      await t.tap(find.text('Terms of Service'));
      await t.pumpAndSettle();
      expect(find.text('Placeholder legal text for TERMS.'), findsOneWidget);
    });
  });

  group('verify', () {
    const location = '/verify?identifier=nia%40example.com&from=%2Fonboarding';

    testWidgets('the button waits for six digits', (t) async {
      await start(t, at: location);
      AtButton button() =>
          t.widget<AtButton>(find.widgetWithText(AtButton, 'Verify'));
      expect(button().onPressed, isNull);
      await typeInto(t, 0, '1234');
      expect(button().onPressed, isNull);
      await typeInto(t, 0, '123456');
      expect(button().onPressed, isNotNull);
    });

    testWidgets('explains why and what comes next', (t) async {
      await start(t, at: location);
      expect(find.textContaining('Why we verify:'), findsOneWidget);
      expect(find.textContaining("What's next:"), findsOneWidget);
    });

    testWidgets('pasting a six digit code is accepted in one go', (t) async {
      await start(t, at: location);
      await typeInto(t, 0, '482913');
      expect(find.text('4'), findsOneWidget);
      expect(find.text('3'), findsWidgets);
    });

    testWidgets('a correct code signs in and continues to onboarding', (
      t,
    ) async {
      final h = await start(
        t,
        at: location,
        onboarding: FakeOnboardingRepository(),
      );
      await typeInto(t, 0, '482913');
      await tapText(t, 'Verify');
      expect(h.auth.calls, contains('verify:nia@example.com:482913'));
      // A brand-new member lands on the first setup step.
      expect(h.path, '/onboarding');
      expect(find.text("Let's set up your creative identity"), findsOneWidget);
      expect(h.events, contains('verification_completed'));
      // Back on the first step leaves setup for Home.
      await t.tap(find.bySemanticsLabel('Back'));
      await t.pumpAndSettle();
      expect(find.byType(AtTabBar), findsOneWidget);
    });

    testWidgets('a wrong code shows the server message and stays', (t) async {
      final auth = FakeAuthRepository(
        verifyFailure: api(
          'VALIDATION_ERROR',
          'That code is not right or has expired.',
        ),
      );
      final h = await start(t, auth: auth, at: location);
      await typeInto(t, 0, '000000');
      await tapText(t, 'Verify');
      expect(
        find.text('That code is not right or has expired.'),
        findsOneWidget,
      );
      expect(h.path, '/verify');
      expect(h.events, isNot(contains('verification_completed')));
    });

    testWidgets('countdown runs, then Resend code works and restarts it', (
      t,
    ) async {
      final h = await start(
        t,
        at: '/verify?identifier=nia%40example.com&resendAt=${DateTime.now().add(const Duration(seconds: 3)).millisecondsSinceEpoch}',
      );
      expect(find.textContaining('Resend in 0:0'), findsOneWidget);
      expect(find.text('Resend code'), findsNothing);
      await t.pump(const Duration(seconds: 4));
      expect(find.text('Resend code'), findsOneWidget);
      await tapText(t, 'Resend code');
      expect(h.auth.calls, contains('resend:nia@example.com'));
      expect(find.text('New code sent.'), findsOneWidget);
      expect(find.textContaining('Resend in 0:5'), findsOneWidget);
    });

    testWidgets('a phone number is verified as a phone number', (t) async {
      await start(t, at: '/verify?identifier=%2B254712345678');
      expect(find.text('Verify your phone number'), findsOneWidget);
    });
  });

  group('sign in', () {
    Future<void> fill(WidgetTester t, String id, String pw) async {
      await typeInto(t, 0, id);
      await typeInto(t, 1, pw);
      await tapText(t, 'Sign in', last: true);
    }

    testWidgets('a wrong password shows the exact banner and stays', (t) async {
      final auth = FakeAuthRepository(
        signInFailure: api(
          'INVALID_CREDENTIALS',
          wrongPasswordMessage,
          status: 401,
        ),
      );
      final h = await start(t, auth: auth, at: '/signin');
      await fill(t, 'nia@example.com', 'wrong-1');
      expect(find.text(wrongPasswordMessage), findsOneWidget);
      expect(h.path, '/signin');
      expect(h.events, isNot(contains('sign_in')));
    });

    testWidgets('the lock-out message points to resetting the password', (
      t,
    ) async {
      final auth = FakeAuthRepository(
        signInFailure: api(
          'RATE_LIMITED',
          'Too many sign-in attempts. Please wait a few minutes or reset your password.',
          status: 429,
          details: {'reason': 'SIGN_IN_LOCKED', 'retryAfterSeconds': 600},
        ),
      );
      await start(t, auth: auth, at: '/signin');
      await fill(t, 'nia@example.com', 'wrong-1');
      expect(find.textContaining('Too many sign-in attempts'), findsOneWidget);
      expect(
        find.textContaining('reset your password to sign in'),
        findsOneWidget,
      );
    });

    testWidgets('an unverified account is taken to the verify screen', (
      t,
    ) async {
      final auth = FakeAuthRepository(
        signInFailure: api(
          'VERIFICATION_REQUIRED',
          'Verify your account to continue.',
          status: 403,
          details: {'reason': 'ACCOUNT_NOT_VERIFIED'},
        ),
      );
      final h = await start(t, auth: auth, at: '/signin');
      await fill(t, 'nia@example.com', 'Passw0rd-1');
      expect(h.path, '/verify');
      expect(find.text('Verify your email'), findsOneWidget);
    });

    testWidgets('an invalid identifier is flagged before any request', (
      t,
    ) async {
      final h = await start(t, at: '/signin');
      await fill(t, 'not an email', 'x');
      expect(
        find.text('Enter a valid email address or phone number.'),
        findsOneWidget,
      );
      expect(h.auth.calls.where((c) => c.startsWith('signIn')), isEmpty);
    });

    testWidgets('success lands on Home and records sign_in', (t) async {
      final h = await start(t, at: '/signin');
      await fill(t, '0712345678', 'Passw0rd-1');
      expect(h.auth.calls, contains('signIn:+254712345678'));
      expect(find.byType(AtTabBar), findsOneWidget);
      expect(h.events, ['sign_in']);
    });

    testWidgets('Forgot password? and Create an account are reachable', (
      t,
    ) async {
      await start(t, at: '/signin');
      await tapText(t, 'Forgot password?');
      expect(find.text('Reset your password'), findsOneWidget);
      await t.tap(find.bySemanticsLabel('Back'));
      await t.pumpAndSettle();
      await tapText(t, 'Create an account');
      expect(find.text('Create your account'), findsOneWidget);
    });
  });

  group('forgot and reset', () {
    testWidgets('asking for a code moves on with the success banner', (
      t,
    ) async {
      final h = await start(t, at: '/forgot');
      await typeInto(t, 0, 'nia@example.com');
      await tapText(t, 'Send code');
      expect(h.auth.calls, contains('forgot:nia@example.com'));
      expect(find.text('Set a new password'), findsOneWidget);
      expect(find.text('Code sent. It expires in 15 minutes.'), findsOneWidget);
      expect(
        find.text("You'll be signed out of other devices."),
        findsOneWidget,
      );
    });

    testWidgets('an invalid identifier is flagged first', (t) async {
      final h = await start(t, at: '/forgot');
      await typeInto(t, 0, 'nope');
      await tapText(t, 'Send code');
      expect(
        find.text('Enter a valid email address or phone number.'),
        findsOneWidget,
      );
      expect(h.auth.calls.where((c) => c.startsWith('forgot')), isEmpty);
    });

    testWidgets('a failed request shows the message', (t) async {
      final auth = FakeAuthRepository(forgotFailure: const NetworkFailure());
      await start(t, auth: auth, at: '/forgot');
      await typeInto(t, 0, 'nia@example.com');
      await tapText(t, 'Send code');
      expect(find.textContaining("You're offline"), findsOneWidget);
    });

    testWidgets('reset checks the code, the rule and the confirmation', (
      t,
    ) async {
      final h = await start(t, at: '/reset?identifier=nia%40example.com');
      await tapText(t, 'Reset password');
      expect(find.text('Enter all 6 digits.'), findsOneWidget);
      expect(
        find.text('Use at least 8 characters, including a number.'),
        findsOneWidget,
      );
      await typeInto(t, 0, '123456');
      await typeInto(t, 1, 'Passw0rd-2');
      await typeInto(t, 2, 'different-3');
      await tapText(t, 'Reset password');
      expect(find.text("The passwords don't match."), findsOneWidget);
      expect(h.auth.calls.where((c) => c.startsWith('reset')), isEmpty);
    });

    testWidgets('a wrong recovery code is shown under the code', (t) async {
      final auth = FakeAuthRepository(
        resetFailure: fieldFailure(
          'code',
          'That code is not right or has expired.',
        ),
      );
      await start(t, auth: auth, at: '/reset?identifier=nia%40example.com');
      await typeInto(t, 0, '123456');
      await typeInto(t, 1, 'Passw0rd-2');
      await typeInto(t, 2, 'Passw0rd-2');
      await tapText(t, 'Reset password');
      expect(
        find.text('That code is not right or has expired.'),
        findsOneWidget,
      );
    });

    testWidgets('success signs in and says other devices were signed out', (
      t,
    ) async {
      final h = await start(t, at: '/reset?identifier=nia%40example.com');
      await typeInto(t, 0, '123456');
      await typeInto(t, 1, 'Passw0rd-2');
      await typeInto(t, 2, 'Passw0rd-2');
      await tapText(t, 'Reset password');
      await t.pumpAndSettle();
      expect(
        h.auth.calls,
        containsAllInOrder([
          'reset:nia@example.com:123456',
          'signIn:nia@example.com',
        ]),
      );
      expect(find.byType(AtTabBar), findsOneWidget);
      expect(
        find.text(
          'Password updated. You were signed out of your other devices.',
        ),
        findsOneWidget,
      );
    });
  });
}
