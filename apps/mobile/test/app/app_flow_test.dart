import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/app/app.dart';
import 'package:atarah/core/config/app_config.dart';
import 'package:atarah/core/connectivity/connectivity_provider.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/core/providers.dart';
import 'package:atarah/core/routing/app_router.dart';
import 'package:atarah/core/storage/token_store.dart';
import 'package:atarah/features/onboarding/onboarding_providers.dart';
import 'package:atarah/features/profile/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/fake_onboarding.dart';
import '../support/fake_profile.dart';
import '../support/fakes.dart';

ProviderContainer? _container;

Widget app(
  FakeAuthRepository repo, {
  Flavor flavor = Flavor.dev,
  Stream<bool>? online,
}) {
  final container = ProviderContainer(
    retry: noAutomaticRetry,
    overrides: [
      appConfigProvider.overrideWithValue(
        AppConfig(flavor: flavor, apiBaseUrl: 'http://test.local'),
      ),
      authRepositoryProvider.overrideWithValue(repo),
      profileRepositoryProvider.overrideWithValue(
        FakeProfileRepository(
          me: ownProfile(name: (repo.restored ?? repo.signInResult).fullName),
        ),
      ),
      onboardingRepositoryProvider.overrideWithValue(
        FakeOnboardingRepository(
          completed: true,
          step: OnboardingStateDtoStep.done,
        ),
      ),
      tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
      isOnlineProvider.overrideWith((ref) => online ?? Stream.value(true)),
    ],
  );
  _container = container;
  addTearDown(container.dispose);
  return UncontrolledProviderScope(
    container: container,
    child: const AtarahApp(),
  );
}

GoRouter router() => _container!.read(appRouterProvider);

Future<void> pumpApp(
  WidgetTester t,
  FakeAuthRepository repo, {
  Flavor flavor = Flavor.dev,
  Stream<bool>? online,
}) async {
  t.view.physicalSize = const Size(390, 844);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(app(repo, flavor: flavor, online: online));
  await t.pumpAndSettle();
}

void main() {
  group('start-up', () {
    testWidgets('no stored session: splash resolves to the welcome screen', (
      t,
    ) async {
      final repo = FakeAuthRepository();
      await pumpApp(t, repo);
      expect(
        find.text('One creative identity. Many connected possibilities.'),
        findsOneWidget,
      );
      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
      expect(repo.calls, ['restore']);
    });

    testWidgets('a stored session opens the tab shell on Home', (t) async {
      await pumpApp(t, FakeAuthRepository(restored: fakeUser()));
      expect(find.byType(AtTabBar), findsOneWidget);
      expect(find.text('Soon · P1'), findsOneWidget);
      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('offline at launch shows a retry, then recovers', (t) async {
      final repo = FakeAuthRepository(
        restored: fakeUser(),
        restoreFailure: const NetworkFailure(),
      );
      await pumpApp(t, repo);
      expect(find.text("Can't reach Atarah"), findsOneWidget);
      await t.tap(find.text('Try again'));
      await t.pumpAndSettle();
      expect(find.byType(AtTabBar), findsOneWidget);
      expect(repo.calls.where((c) => c == 'restore').length, 2);
    });
  });

  group('sign in and out', () {
    testWidgets('sign-in reaches the shell and shows the real member', (
      t,
    ) async {
      final repo = FakeAuthRepository()
        ..signInResult = fakeUser(name: 'Amani Test', pro: true);
      await pumpApp(t, repo);
      await t.tap(find.text('Sign in'));
      await t.pumpAndSettle();
      await t.enterText(
        find.byType(TextField).at(0),
        'amani@test.atarah.local',
      );
      await t.enterText(find.byType(TextField).at(1), 'secret-1');
      await t.tap(find.text('Sign in').last);
      await t.pumpAndSettle();
      expect(repo.calls, contains('signIn:amani@test.atarah.local'));
      expect(find.byType(AtTabBar), findsOneWidget);

      await t.tap(find.text('Profile'));
      await t.pumpAndSettle();
      expect(find.text('Amani Test'), findsOneWidget);
      expect(find.text('Atarah Pro'), findsOneWidget);
    });

    testWidgets(
      'a failed sign-in shows the server message and stays on the form',
      (t) async {
        final repo = FakeAuthRepository(
          signInFailure: const ApiFailure(
            code: 'INVALID_CREDENTIALS',
            message: "That password doesn't match this account. Check it and try again, or reset it.",
            statusCode: 401,
          ),
        );
        await pumpApp(t, repo);
        await t.tap(find.text('Sign in'));
        await t.pumpAndSettle();
        await t.enterText(find.byType(TextField).at(0), 'a@b.co');
        await t.enterText(find.byType(TextField).at(1), 'wrong');
        await t.tap(find.text('Sign in').last);
        await t.pumpAndSettle();
        expect(
          find.textContaining("doesn't match this account"),
          findsOneWidget,
        );
        expect(find.byType(AtTabBar), findsNothing);
      },
    );

    testWidgets('sign out returns to welcome and clears the session', (
      t,
    ) async {
      final repo = FakeAuthRepository(restored: fakeUser());
      await pumpApp(t, repo);
      await t.tap(find.text('Profile'));
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Sign out'));
      await t.tap(find.text('Sign out'));
      await t.pumpAndSettle();
      expect(repo.calls, contains('signOut'));
      expect(
        find.text('One creative identity. Many connected possibilities.'),
        findsOneWidget,
      );
      expect(find.byType(AtTabBar), findsNothing);
    });

    testWidgets('sign in, then return to the intended deep link destination', (
      t,
    ) async {
      final repo = FakeAuthRepository();
      await pumpApp(t, repo);
      router().go('/opportunities/42');
      await t.pumpAndSettle();
      // Signed out: pushed to welcome, remembering the destination.
      expect(router().state.uri.path, '/welcome');
      expect(router().state.uri.queryParameters['from'], '/opportunities/42');

      await t.tap(find.text('Sign in'));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField).at(0), 'a@b.co');
      await t.enterText(find.byType(TextField).at(1), 'secret-1');
      await t.tap(find.text('Sign in').last);
      await t.pumpAndSettle();
      expect(router().state.uri.path, '/opportunities/42');
      expect(find.text('Opportunities'), findsWidgets);
      expect(
        find.byType(AtTabBar),
        findsNothing,
        reason: 'detail screens hide the tab bar',
      );
    });
  });

  group('tab shell', () {
    testWidgets(
      'five tabs in order; each unbuilt tab is a labelled Phase 1 placeholder',
      (t) async {
        await pumpApp(t, FakeAuthRepository(restored: fakeUser()));
        final labels = ['Home', 'Explore', 'Community', 'Opportunities'];
        for (final label in labels) {
          await t.tap(
            find.descendant(
              of: find.byType(AtTabBar),
              matching: find.text(label),
            ),
          );
          await t.pumpAndSettle();
          expect(find.text('Soon · P1'), findsOneWidget, reason: label);
          expect(
            find.text('Go back'),
            findsNothing,
            reason: 'tab roots have no back button',
          );
        }
        await t.tap(
          find.descendant(
            of: find.byType(AtTabBar),
            matching: find.text('Profile'),
          ),
        );
        await t.pumpAndSettle();
        expect(find.text('Test Member'), findsOneWidget);
      },
    );

    testWidgets(
      'every profile entry point opens a real screen or a labelled placeholder',
      (t) async {
        await pumpApp(t, FakeAuthRepository(restored: fakeUser()));
        await t.tap(find.text('Profile'));
        await t.pumpAndSettle();
        for (final (entry, phase) in [
          ('Activity', 'Soon · P1'),
          ('Membership', 'Soon · P2'),
          ('Settings', 'Soon · P1'),
        ]) {
          await t.ensureVisible(find.text(entry));
          await t.tap(find.text(entry));
          await t.pumpAndSettle();
          expect(find.text(phase), findsOneWidget, reason: entry);
          expect(
            find.byType(AtTabBar),
            findsNothing,
            reason: 'placeholder screens hide the tab bar',
          );
          await t.tap(find.text('Go back'));
          await t.pumpAndSettle();
          expect(find.byType(AtTabBar), findsOneWidget);
        }
      },
    );

    testWidgets('tapping the active tab returns to its root', (t) async {
      await pumpApp(t, FakeAuthRepository(restored: fakeUser()));
      await t.tap(find.text('Profile'));
      await t.pumpAndSettle();
      expect(router().state.uri.path, '/profile');
      await t.tap(
        find.descendant(
          of: find.byType(AtTabBar),
          matching: find.text('Profile'),
        ),
      );
      await t.pumpAndSettle();
      expect(router().state.uri.path, '/profile');
    });
  });

  group('deep links', () {
    const links = {
      '/opportunities/42': 'Soon · P1',
      '/learning/courses/3': 'Soon · P1',
      '/learning/lessons/3': 'Soon · P1',
      '/marketplace/listings/5': 'Soon · P2',
      '/mentors/7': 'Soon · P2',
      '/articles/a-slug': 'Soon · P1',
      '/groups/12': 'Soon · P1',
      '/posts/77': 'Soon · P1',
      '/notifications': 'Soon · P1',
      '/soon/p3?name=Contextual%20AI': 'Soon · P3',
      '/soon/later?name=Wellness%20Zone': 'Soon · Later',
    };
    links.forEach((path, label) {
      testWidgets('$path opens its screen labelled "$label"', (t) async {
        await pumpApp(t, FakeAuthRepository(restored: fakeUser()));
        router().go(path);
        await t.pumpAndSettle();
        expect(find.text(label), findsOneWidget);
        expect(find.byType(AtTabBar), findsNothing);
      });
    });

    testWidgets(
      'a deep link while a session is being restored is remembered and honoured',
      (t) async {
        final repo = FakeAuthRepository(restored: fakeUser());
        t.view.physicalSize = const Size(390, 844);
        t.view.devicePixelRatio = 1.0;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        await t.pumpWidget(app(repo));
        router().go('/mentors/7'); // arrives before the session check completed
        await t.pumpAndSettle();
        expect(router().state.uri.path, '/mentors/7');
        expect(find.text('Soon · P2'), findsOneWidget);
      },
    );
  });

  group('offline banner', () {
    testWidgets('appears with the exact copy when the device goes offline', (
      t,
    ) async {
      await pumpApp(
        t,
        FakeAuthRepository(restored: fakeUser()),
        online: Stream.value(false),
      );
      expect(
        find.text("You're offline. Saved content is still available."),
        findsOneWidget,
      );
    });

    testWidgets('is absent while online', (t) async {
      await pumpApp(t, FakeAuthRepository(restored: fakeUser()));
      expect(find.byType(AtOfflineBanner), findsNothing);
    });
  });

  group('developer gallery', () {
    testWidgets('exists in the dev flavour and not in production', (t) async {
      await pumpApp(t, FakeAuthRepository(restored: fakeUser()));
      router().go('/dev/gallery');
      await t.pump(
        const Duration(milliseconds: 600),
      ); // skeletons animate forever
      expect(find.text('Component gallery'), findsOneWidget);

      await pumpApp(
        t,
        FakeAuthRepository(restored: fakeUser()),
        flavor: Flavor.prod,
      );
      router().go('/dev/gallery');
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('Component gallery'), findsNothing);
    });
  });
}
