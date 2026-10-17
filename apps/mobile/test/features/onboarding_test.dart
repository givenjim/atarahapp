import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/features/onboarding/device_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/fake_onboarding.dart';
import '../support/fakes.dart';

/// Opens the app signed in with an unfinished profile, so the router resumes setup.
Future<Harness> open(
  WidgetTester t, {
  FakeOnboardingRepository? repo,
  FakeLocationLookup? location,
  FakePhotoPicker? picker,
}) async {
  final h = Harness(
    auth: FakeAuthRepository(restored: fakeUser(name: 'Nia Wairimu')),
    onboarding: repo ?? FakeOnboardingRepository(),
    location: location,
    picker: picker,
  );
  await h.pump(t);
  return h;
}

Future<void> next(WidgetTester t, [String label = 'Continue']) async {
  await tapText(t, label, last: true);
}

Future<void> pickCounty(WidgetTester t, String name) async {
  await tapText(t, 'Select', last: true);
  await tapText(t, name);
}

Finder field(int i) => find.byType(TextField).at(i);

void main() {
  group('resume', () {
    testWidgets('a new member starts at the intro with no Skip', (t) async {
      final h = await open(t);
      expect(h.path, '/onboarding');
      expect(find.text("Let's set up your creative identity"), findsOneWidget);
      expect(find.text('Your discipline'), findsOneWidget);
      expect(find.text('Skills & interests'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Profile basics'), findsOneWidget);
      expect(find.text('Getting started'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);
      expect(find.text('Skip'), findsNothing);
    });

    testWidgets(
      'a member who stopped at location resumes there with their answers',
      (t) async {
        final repo =
            FakeOnboardingRepository(step: OnboardingStateDtoStep.location)
              ..disciplineId = 'd-animation'
              ..skillIds = {'k-ae', 'k-pro'};
        await open(t, repo: repo);
        expect(find.text('Where are you based?'), findsOneWidget);
        expect(find.text('Step 4 of 6'), findsOneWidget);
        // Going back shows what was saved earlier.
        await t.tap(find.bySemanticsLabel('Back'));
        await t.pumpAndSettle();
        expect(find.text('2 selected'), findsOneWidget);
        expect(find.text('After Effects'), findsOneWidget);
      },
    );

    testWidgets('a finished member never sees setup', (t) async {
      final repo = FakeOnboardingRepository(
        step: OnboardingStateDtoStep.done,
        completed: true,
      );
      final h = await open(t, repo: repo);
      expect(h.path, '/home');
      expect(find.byType(AtTabBar), findsOneWidget);
    });

    testWidgets('if the setup state cannot load, the member is not trapped', (
      t,
    ) async {
      final repo = FakeOnboardingRepository(
        stateFailure: const NetworkFailure(),
      );
      final h = await open(t, repo: repo);
      expect(h.path, '/home');
    });
  });

  group('discipline', () {
    testWidgets('Continue needs a choice and sends nothing without one', (
      t,
    ) async {
      final repo = FakeOnboardingRepository(
        step: OnboardingStateDtoStep.discipline,
      );
      await open(t, repo: repo);
      await next(t);
      expect(
        find.text('Choose what you create, or skip this step.'),
        findsOneWidget,
      );
      expect(repo.saves, isEmpty);
    });

    testWidgets(
      'choosing a discipline saves it and opens its specialisations',
      (t) async {
        final repo = FakeOnboardingRepository(
          step: OnboardingStateDtoStep.discipline,
        );
        final h = await open(t, repo: repo);
        expect(find.text('Step 1 of 6'), findsOneWidget);
        await tapText(t, 'Animation');
        await next(t);
        expect(repo.saves.single.disciplineId, 'd-animation');
        expect(find.text('Your specialization'), findsOneWidget);
        expect(find.text('2D animation'), findsOneWidget);
        expect(find.text('Singer'), findsNothing);
        expect(h.events, contains('onboarding_step_completed'));
      },
    );

    testWidgets(
      'a server failure shows a banner and keeps the member on the step',
      (t) async {
        final repo = FakeOnboardingRepository(
          step: OnboardingStateDtoStep.discipline,
        )..saveFailure = const NetworkFailure();
        await open(t, repo: repo);
        await tapText(t, 'Animation');
        await next(t);
        expect(
          find.text("You're offline. Check your connection and try again."),
          findsOneWidget,
        );
        expect(find.text('What do you create?'), findsOneWidget);
        // Retrying after the connection returns works.
        repo.saveFailure = null;
        await next(t);
        expect(find.text('Your specialization'), findsOneWidget);
      },
    );
  });

  group('specialisation', () {
    FakeOnboardingRepository seeded() =>
        FakeOnboardingRepository(step: OnboardingStateDtoStep.specialisation)
          ..disciplineId = 'd-animation';

    testWidgets('multi-select rows are saved together', (t) async {
      final repo = seeded();
      await open(t, repo: repo);
      expect(
        find.text(
          'Within Animation — pick any that describe your practice.',
          findRichText: true,
        ),
        findsOneWidget,
      );
      await tapText(t, '2D animation');
      await tapText(t, 'Character design');
      await next(t);
      expect(
        repo.saves.single.specialisationIds,
        unorderedEquals(['s-2d', 's-char']),
      );
      expect(find.text('Skills & interests'), findsWidgets);
    });

    testWidgets('changing the discipline clears the specialisations', (
      t,
    ) async {
      final repo = seeded()..specialisationIds = {'s-2d'};
      await open(t, repo: repo);
      await t.tap(find.bySemanticsLabel('Back'));
      await t.pumpAndSettle();
      await tapText(t, 'Music');
      await next(t);
      expect(repo.specialisationIds, isEmpty);
      expect(find.text('Singer'), findsOneWidget);
      expect(find.text('2D animation'), findsNothing);
    });

    testWidgets('suggesting a specialisation goes to the review queue', (
      t,
    ) async {
      final repo = seeded();
      await open(t, repo: repo);
      await tapText(t, 'Suggest a specialization');
      await t.enterText(find.byType(TextField).last, 'Puppetry');
      await tapText(t, 'Send suggestion');
      expect(repo.suggestions.single, (
        disciplineId: 'd-animation',
        name: 'Puppetry',
      ));
      expect(find.text("Thanks, we'll take a look"), findsOneWidget);
      await tapText(t, 'Done');
      expect(find.text('Your specialization'), findsOneWidget);
    });

    testWidgets('an empty or duplicate suggestion explains itself', (t) async {
      final repo = FakeOnboardingRepository(
        step: OnboardingStateDtoStep.specialisation,
      )..disciplineId = 'd-music';
      await open(t, repo: repo);
      await tapText(t, 'Suggest a specialization');
      await tapText(t, 'Send suggestion');
      expect(find.text('Enter a name for the specialization.'), findsOneWidget);
      await t.enterText(find.byType(TextField).last, 'Singer');
      await tapText(t, 'Send suggestion');
      expect(find.textContaining('already in the Music list'), findsOneWidget);
      expect(repo.suggestions, isEmpty);
    });

    testWidgets('without a discipline the step says what to do first', (
      t,
    ) async {
      await open(
        t,
        repo: FakeOnboardingRepository(
          step: OnboardingStateDtoStep.specialisation,
        ),
      );
      expect(
        find.textContaining('Choose your discipline first'),
        findsOneWidget,
      );
    });
  });

  group('skills, interests and areas', () {
    testWidgets(
      'chips toggle, counters follow, and all three lists are saved',
      (t) async {
        final repo = FakeOnboardingRepository(
          step: OnboardingStateDtoStep.skills,
        )..disciplineId = 'd-animation';
        await open(t, repo: repo);
        expect(find.text('0 selected'), findsNWidgets(3));
        await tapText(t, 'After Effects');
        await tapText(t, 'Procreate');
        await tapText(t, 'Comics');
        await tapText(t, 'Pricing my work');
        expect(find.text('2 selected'), findsOneWidget);
        await tapText(t, 'Procreate'); // toggles off
        expect(find.text('1 selected'), findsNWidgets(3));
        await next(t);
        final save = repo.saves.single;
        expect(save.skillIds, ['k-ae']);
        expect(save.interestIds, ['i-comics']);
        expect(save.developmentAreaIds, ['a-price']);
        expect(find.text('Where are you based?'), findsOneWidget);
      },
    );
  });

  group('location', () {
    FakeOnboardingRepository seeded() =>
        FakeOnboardingRepository(step: OnboardingStateDtoStep.location);

    testWidgets('a county is required to continue', (t) async {
      final repo = seeded();
      await open(t, repo: repo);
      await next(t);
      expect(
        find.text('Choose your county, or skip this step.'),
        findsOneWidget,
      );
      expect(repo.saves, isEmpty);
    });

    testWidgets('picking a county, a town and who can see it', (t) async {
      final repo = seeded();
      await open(t, repo: repo);
      expect(
        find.text('Kenya'),
        findsOneWidget,
      ); // the only country is chosen for the member
      await pickCounty(t, 'Nairobi');
      await t.enterText(find.byType(TextField).first, 'Kilimani');
      expect(
        find.text('Only signed-in Atarah members can see your county.'),
        findsOneWidget,
      );
      await tapText(t, 'Public');
      expect(
        find.text(
          'Anyone, including people outside Atarah, can see your county.',
        ),
        findsOneWidget,
      );
      await tapText(t, 'Private');
      expect(
        find.text(
          'Hidden from everyone. Still used to personalise what you see.',
        ),
        findsOneWidget,
      );
      await next(t);
      final save = repo.saves.single;
      expect(save.countyId, 'n-nbi');
      expect(save.town, 'Kilimani');
      expect(
        save.locationVisibility,
        SaveOnboardingStepDtoLocationVisibility.private,
      );
      expect(find.text('Introduce yourself'), findsOneWidget);
    });

    testWidgets('the county list can be searched', (t) async {
      await open(t, repo: seeded());
      await tapText(t, 'Select', last: true);
      await t.enterText(find.byType(TextField).last, 'kis');
      await t.pumpAndSettle();
      expect(find.text('Kisumu'), findsOneWidget);
      expect(find.text('Mombasa'), findsNothing);
      await t.enterText(find.byType(TextField).last, 'zzz');
      await t.pumpAndSettle();
      expect(find.text('Nothing matches that.'), findsOneWidget);
    });

    testWidgets('"Use my current location" fills the county from the phone', (
      t,
    ) async {
      final location = FakeLocationLookup();
      await open(t, repo: seeded(), location: location);
      await tapText(t, 'Use my current location');
      expect(location.calls, 1);
      expect(find.text('We set your county to Nairobi.'), findsOneWidget);
      expect(find.text('Nairobi'), findsOneWidget);
    });

    for (final c in [
      (
        LocationProblem.permissionDenied,
        'Location permission is off. Choose your county from the list.',
      ),
      (
        LocationProblem.permissionDeniedForever,
        'Location is blocked for Atarah in your phone settings. Choose your county from the list.',
      ),
      (
        LocationProblem.servicesOff,
        'Location is switched off on this phone. Choose your county from the list.',
      ),
      (
        LocationProblem.unavailable,
        "We couldn't get your location. Choose your county from the list.",
      ),
    ]) {
      testWidgets(
        'location problem ${c.$1.name} says what happened and leaves the list usable',
        (t) async {
          await open(
            t,
            repo: seeded(),
            location: FakeLocationLookup(problem: c.$1),
          );
          await tapText(t, 'Use my current location');
          expect(find.text(c.$2), findsOneWidget);
          await pickCounty(t, 'Mombasa');
          expect(find.text('Mombasa'), findsOneWidget);
        },
      );
    }

    testWidgets('a place we cannot match to a county is not guessed', (
      t,
    ) async {
      await open(
        t,
        repo: seeded(),
        location: FakeLocationLookup(names: ['Atlantis']),
      );
      await tapText(t, 'Use my current location');
      expect(
        find.text(
          "We couldn't match your location to a county. Choose it from the list.",
        ),
        findsOneWidget,
      );
    });
  });

  group('basics', () {
    FakeOnboardingRepository seeded() =>
        FakeOnboardingRepository(step: OnboardingStateDtoStep.basics);

    testWidgets(
      'the profile link is suggested from the name and checked live',
      (t) async {
        final repo = seeded();
        await open(t, repo: repo);
        expect(find.text('Introduce yourself'), findsOneWidget);
        await t.pump(const Duration(milliseconds: 600));
        expect(repo.handleChecks, contains('niawairimu'));
        expect(find.text('niawairimu is available.'), findsOneWidget);
      },
    );

    testWidgets('a taken link shows why and offers free alternatives', (
      t,
    ) async {
      final repo = seeded()..takenHandles.add('niawairimu');
      await open(t, repo: repo);
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('That profile link is taken.'), findsOneWidget);
      expect(find.text('niawairimu2'), findsOneWidget);
      await tapText(t, 'niawairimu2');
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('niawairimu2 is available.'), findsOneWidget);
      expect(find.text('That profile link is taken.'), findsNothing);
    });

    testWidgets('format and reserved words are explained', (t) async {
      final repo = seeded();
      await open(t, repo: repo);
      await t.enterText(field(1), 'no spaces!');
      await t.pump();
      expect(
        find.text('Use 3 to 30 letters, numbers or underscores.'),
        findsOneWidget,
      );
      await t.enterText(field(1), 'admin');
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('That link is reserved. Try another.'), findsOneWidget);
      // The invalid link cannot be saved.
      await next(t);
      expect(repo.saves, isEmpty);
    });

    testWidgets('name and link are required; the bio counter and limit work', (
      t,
    ) async {
      final repo = seeded();
      await open(t, repo: repo);
      await t.enterText(field(0), 'N');
      await t.enterText(field(1), '');
      await next(t);
      expect(
        find.text('Enter the name you want people to see.'),
        findsOneWidget,
      );
      expect(find.text('Choose your profile link.'), findsOneWidget);
      expect(repo.saves, isEmpty);

      await t.enterText(field(2), 'Illustrator in Nairobi.');
      await t.pump();
      expect(find.text('23 / 160'), findsOneWidget);
    });

    testWidgets('saves name, link and bio together, lower-cased and trimmed', (
      t,
    ) async {
      final repo = seeded();
      await open(t, repo: repo);
      await t.enterText(field(0), '  Nia W.  ');
      await t.enterText(field(1), 'Nia_W');
      await t.enterText(field(2), '  Illustrator and 2D animator.  ');
      await t.pump(const Duration(milliseconds: 600));
      await next(t);
      final save = repo.saves.single;
      expect(save.displayName, 'Nia W.');
      expect(save.handle, 'nia_w');
      expect(save.bio, 'Illustrator and 2D animator.');
      expect(find.text('Add a profile photo'), findsOneWidget);
    });

    testWidgets(
      'a link taken at the last moment is shown under the field with alternatives',
      (t) async {
        final repo = seeded();
        await open(t, repo: repo);
        await t.pump(const Duration(milliseconds: 600));
        // Someone else claims it between the live check and Continue.
        repo.takenHandles.add('niawairimu');
        await next(t);
        expect(find.text('That profile link is taken.'), findsOneWidget);
        expect(find.text('niawairimu2'), findsOneWidget);
        expect(find.text('Add a profile photo'), findsNothing);
      },
    );

    testWidgets('"Help me write this" opens the labelled Phase 3 screen', (
      t,
    ) async {
      await open(t, repo: seeded());
      await tapText(t, 'Help me write this');
      expect(find.text('Soon · P3'), findsOneWidget);
    });
  });

  group('photo and finishing', () {
    FakeOnboardingRepository seeded() =>
        FakeOnboardingRepository(step: OnboardingStateDtoStep.photo)
          ..disciplineId = 'd-animation'
          ..specialisationIds = {'s-2d'}
          ..countyId = 'n-nbi'
          ..handle = 'niawairimu';

    testWidgets('a picked photo is cropped, uploaded and can be removed', (
      t,
    ) async {
      final repo = seeded();
      final picker = FakePhotoPicker();
      await open(t, repo: repo, picker: picker);
      await tapText(t, 'Gallery');
      expect(picker.requests, [false]);
      expect(repo.uploads, 1);
      expect(find.text('Photo added.'), findsOneWidget);
      await tapText(t, 'Remove photo');
      expect(repo.removals, 1);
      expect(find.text('Photo added.'), findsNothing);
      await tapText(t, 'Take photo');
      expect(picker.requests, [false, true]);
    });

    testWidgets('cancelling the picker changes nothing', (t) async {
      final repo = seeded();
      await open(t, repo: repo, picker: FakePhotoPicker.cancelling());
      await tapText(t, 'Gallery');
      expect(repo.uploads, 0);
    });

    testWidgets('an upload the server refuses is explained', (t) async {
      final repo = seeded()
        ..uploadFailure = 'This type of file is not supported.';
      await open(t, repo: repo);
      await tapText(t, 'Gallery');
      expect(find.text('This type of file is not supported.'), findsOneWidget);
      expect(find.text('Photo added.'), findsNothing);
    });

    testWidgets(
      'Finish completes setup and shows the real Passport and completion',
      (t) async {
        final repo = seeded()
          ..skillIds = {'k-ae', 'k-pro', 'k-story'}
          ..bio = 'Illustrator and 2D animator in Nairobi.';
        final h = await open(t, repo: repo);
        await tapText(t, 'Gallery');
        await next(t, 'Finish');
        expect(repo.completeCalls, 1);
        expect(repo.saves.last.step, SaveOnboardingStepDtoStep.photo);
        expect(find.text('Your creative journey starts here.'), findsOneWidget);
        expect(find.text('ATR · NBI · 0042'), findsOneWidget);
        expect(find.text('Nia Wairimu'), findsOneWidget);
        expect(find.text('Animation · 2D animation'), findsOneWidget);
        expect(find.text('Nairobi, Kenya'), findsOneWidget);
        // photo 15 + bio 10 + discipline 10 + specialisation 10 + skills 10 + location 10 + contact 5
        expect(find.text('70%'), findsOneWidget);
        expect(h.events, contains('onboarding_completed'));

        await tapText(t, 'Go to Home');
        expect(h.path, '/home');
        expect(find.byType(AtTabBar), findsOneWidget);
        // Setup is closed for good: reopening it goes straight home.
        h.router.go('/onboarding');
        await t.pumpAndSettle();
        expect(h.path, '/home');
      },
    );

    testWidgets(
      'a member who skipped everything still finishes, with honest placeholders',
      (t) async {
        final repo = FakeOnboardingRepository(
          step: OnboardingStateDtoStep.photo,
        );
        await open(t, repo: repo);
        await tapText(t, 'Skip for now');
        expect(repo.saves.single.skipped, isTrue);
        expect(repo.completeCalls, 1);
        expect(find.text('ATR · GEN · 0042'), findsOneWidget);
        expect(find.text('Specialization not set'), findsOneWidget);
        expect(find.text('Location not set'), findsOneWidget);
        expect(find.text('5%'), findsOneWidget);
      },
    );

    testWidgets('a failure at the end keeps the member on the photo step', (
      t,
    ) async {
      final repo = seeded()..saveFailure = const NetworkFailure(timedOut: true);
      await open(t, repo: repo);
      await next(t, 'Finish');
      expect(
        find.text('That took too long. Check your connection and try again.'),
        findsOneWidget,
      );
      expect(repo.completeCalls, 0);
      repo.saveFailure = null;
      await next(t, 'Finish');
      expect(find.text('Your creative journey starts here.'), findsOneWidget);
    });
  });

  group('skip and back', () {
    testWidgets('Skip saves nothing for the step and moves on', (t) async {
      final repo = FakeOnboardingRepository(
        step: OnboardingStateDtoStep.discipline,
      );
      await open(t, repo: repo);
      await tapText(t, 'Animation');
      await tapText(t, 'Skip');
      expect(repo.saves.single.skipped, isTrue);
      expect(repo.disciplineId, isNull);
      expect(find.text('Your specialization'), findsOneWidget);
    });

    testWidgets('Back returns to the previous step without a request', (
      t,
    ) async {
      final repo = FakeOnboardingRepository(
        step: OnboardingStateDtoStep.skills,
      );
      await open(t, repo: repo);
      await t.tap(find.bySemanticsLabel('Back'));
      await t.pumpAndSettle();
      expect(find.text('Your specialization'), findsOneWidget);
      expect(repo.saves, isEmpty);
    });

    testWidgets('the progress bar and step label follow the member', (t) async {
      await open(t, repo: FakeOnboardingRepository());
      Finder bar() => find.byType(AtProgressBar);
      expect(t.widget<AtProgressBar>(bar()).value, 1 / 8);
      await next(t, 'Get started');
      expect(find.text('Step 1 of 6'), findsOneWidget);
      expect(t.widget<AtProgressBar>(bar()).value, 2 / 8);
    });
  });

  group('loading', () {
    testWidgets(
      'a state that fails to load on the setup screen offers a retry',
      (t) async {
        final repo = FakeOnboardingRepository()
          ..stateFailure = const NetworkFailure();
        final h = Harness(
          auth: FakeAuthRepository(restored: fakeUser()),
          onboarding: repo,
        );
        await h.pump(t);
        expect(h.path, '/home'); // the gate lets the member through
        h.router.go('/onboarding');
        await t.pumpAndSettle();
        expect(find.text("We couldn't load your setup"), findsOneWidget);
        expect(
          find.text("You're offline. Check your connection and try again."),
          findsOneWidget,
        );
        await tapText(t, 'Try again');
        expect(
          find.text("Let's set up your creative identity"),
          findsOneWidget,
        );
      },
    );
  });

  group('large text', () {
    for (final step in [
      OnboardingStateDtoStep.intro,
      OnboardingStateDtoStep.discipline,
      OnboardingStateDtoStep.specialisation,
      OnboardingStateDtoStep.skills,
      OnboardingStateDtoStep.location,
      OnboardingStateDtoStep.basics,
      OnboardingStateDtoStep.photo,
    ]) {
      testWidgets('${step.json} lays out at 200% text without overflow', (
        t,
      ) async {
        t.platformDispatcher.textScaleFactorTestValue = 2.0;
        addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
        final repo = FakeOnboardingRepository(step: step)
          ..disciplineId = 'd-animation';
        await open(t, repo: repo);
        expect(t.takeException(), isNull);
        expect(find.byType(AtButton), findsWidgets);
      });
    }
  });
}
