import 'package:atarah/core/auth/session_controller.dart';
import 'package:atarah/core/routing/redirect.dart';
import 'package:flutter_test/flutter_test.dart';

String? redirect(
  SessionStatus status,
  String location, {
  bool devTools = true,
}) => computeRedirect(
  status: status,
  uri: Uri.parse(location),
  devTools: devTools,
);

void main() {
  group('while the session is being checked', () {
    for (final status in [SessionStatus.checking, SessionStatus.failed]) {
      test('$status: everything shows the splash, remembering a deep link', () {
        expect(redirect(status, '/home'), '/splash?from=%2Fhome');
        expect(
          redirect(status, '/opportunities/42?ref=push'),
          '/splash?from=${Uri.encodeQueryComponent('/opportunities/42?ref=push')}',
        );
        expect(redirect(status, '/splash'), isNull);
      });

      test('$status: does not remember an auth screen as the destination', () {
        expect(redirect(status, '/welcome'), '/splash');
      });
    }
  });

  group('signed out', () {
    test('splash goes to welcome, keeping the remembered destination', () {
      expect(redirect(SessionStatus.signedOut, '/splash'), '/welcome');
      expect(
        redirect(SessionStatus.signedOut, '/splash?from=%2Fmentors%2F7'),
        '/welcome?from=%2Fmentors%2F7',
      );
    });

    test(
      'protected routes go to welcome and remember where the member was headed',
      () {
        expect(
          redirect(SessionStatus.signedOut, '/opportunities/42'),
          '/welcome?from=%2Fopportunities%2F42',
        );
        expect(
          redirect(SessionStatus.signedOut, '/home'),
          '/welcome?from=%2Fhome',
        );
        expect(
          redirect(SessionStatus.signedOut, '/profile'),
          '/welcome?from=%2Fprofile',
        );
      },
    );

    test('the whole sign-in family and the legal text are public', () {
      for (final p in [
        '/welcome',
        '/signup',
        '/signin',
        '/verify?identifier=a%40b.co',
        '/forgot',
        '/reset?identifier=a%40b.co',
        '/legal/TERMS',
        '/legal/PRIVACY',
        '/dev/gallery',
      ]) {
        expect(redirect(SessionStatus.signedOut, p), isNull, reason: p);
      }
    });

    test('the onboarding entry and the app itself need a session', () {
      expect(
        redirect(SessionStatus.signedOut, '/onboarding'),
        '/welcome?from=%2Fonboarding',
      );
      expect(
        redirect(SessionStatus.signedOut, '/home'),
        startsWith('/welcome'),
      );
    });

    test('the developer gallery only exists with dev tools', () {
      expect(
        redirect(SessionStatus.signedOut, '/dev/gallery', devTools: false),
        startsWith('/welcome'),
      );
    });
  });

  group('signed in', () {
    test(
      'auth screens are skipped: go home, or to the remembered destination',
      () {
        expect(redirect(SessionStatus.signedIn, '/splash'), '/home');
        expect(redirect(SessionStatus.signedIn, '/welcome'), '/home');
        for (final p in ['/signup', '/signin', '/forgot']) {
          expect(redirect(SessionStatus.signedIn, p), '/home', reason: p);
        }
        // A new member who just verified is sent on to onboarding.
        expect(
          redirect(
            SessionStatus.signedIn,
            '/verify?identifier=a%40b.co&from=%2Fonboarding',
          ),
          '/onboarding',
        );
        expect(
          redirect(
            SessionStatus.signedIn,
            '/welcome?from=%2Fopportunities%2F42',
          ),
          '/opportunities/42',
        );
        expect(
          redirect(SessionStatus.signedIn, '/splash?from=%2Fmentors%2F7'),
          '/mentors/7',
        );
      },
    );

    test('everything else is left alone', () {
      for (final p in [
        '/home',
        '/profile',
        '/opportunities/42',
        '/soon/p2',
        '/dev/gallery',
      ]) {
        expect(redirect(SessionStatus.signedIn, p), isNull, reason: p);
      }
    });
  });

  group('safeDestination (no open redirects)', () {
    test('accepts in-app absolute paths with queries', () {
      expect(safeDestination('/home'), '/home');
      expect(safeDestination('/opportunities/42?x=1'), '/opportunities/42?x=1');
    });

    test(
      'rejects external, protocol-relative, relative, empty and auth paths',
      () {
        for (final bad in [
          null,
          '',
          'https://evil.example/phish',
          '//evil.example',
          'home',
          'javascript:alert(1)',
          '/welcome',
          '/splash',
          '/signin',
          '/signup',
          '/verify',
        ]) {
          expect(safeDestination(bad), isNull, reason: '$bad');
        }
      },
    );

    test('a malicious from= falls back to home after sign-in', () {
      expect(
        redirect(
          SessionStatus.signedIn,
          '/welcome?from=${Uri.encodeQueryComponent('https://evil.example')}',
        ),
        '/home',
      );
    });
  });
}
