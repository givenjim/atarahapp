import 'dart:async';

import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/fake_onboarding.dart';
import '../support/fake_portfolio.dart';
import '../support/fake_profile.dart';
import '../support/fakes.dart';

/// P1-M12 journey (a), fake-backed: a new creative signs up, verifies, completes setup, lands on Home, adds a
/// project and opens their public profile. The same journey runs against the real backend in
/// `integration_test/journey_new_creative_test.dart` (written, not run: no emulator).
void main() {
  testWidgets(
    'sign up, verify, onboarding, home, add project, public profile',
    (t) async {
      final onboarding = FakeOnboardingRepository(displayName: 'Nia Wairimu');
      final portfolio = FakePortfolioRepository();
      final profile = FakeProfileRepository();
      profile.creatives['nia_w'] = (preview) => publicProfile(
        handle: 'nia_w',
        name: 'Nia Wairimu',
        relation: PublicProfileDtoRelation.anonymous,
        connection: null,
      );
      final auth = FakeAuthRepository()
        ..verifyResult = fakeUser(name: 'Nia Wairimu');
      final h = Harness(
        auth: auth,
        onboarding: onboarding,
        portfolio: portfolio,
        profile: profile,
      );
      await h.pump(t);

      // Sign up.
      expect(h.path, '/welcome');
      await tapText(t, 'Create account');
      await typeInto(t, 0, 'Nia Wairimu');
      await typeInto(t, 1, 'nia.new@example.com');
      await typeInto(t, 2, 'Journey-pass-1');
      await t.tap(find.byType(AtCheckbox));
      await t.pump();
      await tapText(t, 'Continue');
      expect(auth.calls, contains('register:nia.new@example.com'));

      // Verify.
      expect(find.text('Verify your email'), findsOneWidget);
      await t.enterText(find.byType(TextField).first, '123456');
      await t.pump();
      await tapText(t, 'Verify');
      expect(auth.calls, contains('verify:nia.new@example.com:123456'));

      // Setup resumes at the intro, a step at a time.
      expect(h.path, '/onboarding');
      expect(find.text("Let's set up your creative identity"), findsOneWidget);
      await tapText(t, 'Get started');
      await tapText(t, 'Animation');
      await tapText(t, 'Continue', last: true);
      await tapText(t, '2D animation');
      await tapText(t, 'Continue', last: true);
      await tapText(t, 'After Effects');
      await tapText(t, 'Continue', last: true);
      await tapText(t, 'Use my current location');
      expect(find.text('We set your county to Nairobi.'), findsOneWidget);
      await tapText(t, 'Continue', last: true);
      expect(find.text('Introduce yourself'), findsOneWidget);
      await t.enterText(find.byType(TextField).at(0), 'Nia Wairimu');
      await t.enterText(find.byType(TextField).at(1), 'nia_w');
      await t.enterText(
        find.byType(TextField).at(2),
        'Illustrator and 2D animator in Nairobi.',
      );
      await t.pump(const Duration(milliseconds: 600));
      await t.pumpAndSettle();
      await tapText(t, 'Continue', last: true);
      expect(find.text('Add a profile photo'), findsOneWidget);
      await tapText(t, 'Skip for now');
      expect(find.text('Your creative journey starts here.'), findsOneWidget);
      expect(onboarding.completeCalls, 1);

      // Home.
      await tapText(t, 'Go to Home');
      expect(h.path, '/home');
      expect(find.byType(AtTabBar), findsOneWidget);
      expect(h.events, contains('onboarding_completed'));

      // Add a project. A tall window so the whole editor is built.
      t.view.physicalSize = const Size(390, 3000);
      h.router.go('/portfolio');
      await t.pumpAndSettle();
      expect(find.text('Add project'), findsWidgets);
      unawaited(h.router.push('/portfolio/new/edit'));
      await t.pumpAndSettle();
      await t.enterText(
        find.descendant(
          of: find.byWidgetPredicate(
            (w) => w is AtTextField && w.label == 'Title',
          ),
          matching: find.byType(TextField),
        ),
        'Mama Mboga',
      );
      await tapText(t, 'Publish');
      expect(portfolio.projects.single.title, 'Mama Mboga');
      expect(portfolio.projects.single.status, ProjectDtoStatus.published);
      expect(h.path, '/portfolio');
      expect(find.text('Mama Mboga'), findsOneWidget);

      // Public profile.
      h.router.go('/creatives/nia_w');
      await t.pumpAndSettle();
      expect(find.text('Nia Wairimu'), findsWidgets);
      expect(t.takeException(), isNull);
    },
  );
}
