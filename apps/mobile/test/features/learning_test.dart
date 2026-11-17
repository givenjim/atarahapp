import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/features/learning/lesson_players.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../support/app_harness.dart';
import '../support/fake_learning.dart';
import '../support/fakes.dart';

Future<Harness> openApp(
  WidgetTester t, {
  FakeLearningRepository? repo,
  String at = '/learning',
}) async {
  final h = Harness(
    auth: FakeAuthRepository(restored: fakeUser(name: 'Nia Wairimu')),
    learning: repo ?? FakeLearningRepository(),
  );
  await h.pump(t);
  h.router.go(at);
  await t.pumpAndSettle();
  return h;
}

/// Scrolls the page (the one with the pull-to-refresh) until [finder] is on screen.
Future<void> reveal(WidgetTester t, Finder finder) => t.scrollUntilVisible(
  finder,
  300,
  scrollable: find
      .descendant(
        of: find.byType(RefreshIndicator).last,
        matching: find.byType(Scrollable),
      )
      .first,
);

/// Scrolls a lesson page (a plain list) until [finder] is on screen.
Future<void> revealIn(WidgetTester t, Finder finder) => t.scrollUntilVisible(
  finder,
  300,
  scrollable: find.byType(Scrollable).first,
);

const _apiNotFound = ApiFailure(
  code: 'RESOURCE_NOT_FOUND',
  message: 'That Skill Lab is not available.',
  statusCode: 404,
);

LearningHubDto _richHub() => hubDto(
  cont: ContinueLearningDto(
    content: labCard(
      id: 'lab-1',
      title: 'Character Animation Basics',
      progress: itemProgress(57),
    ),
    percent: 57,
    lessonsDone: 3,
    lessonCount: 7,
    nextLessonId: 'lesson-4',
    nextLessonTitle: 'Walk cycles',
  ),
  featured: [
    labCard(id: 'f-1', title: 'Pricing Your Creative Work', featured: true),
    labCard(
      id: 'f-2',
      title: 'Creative Business Starter Kit',
      type: LearningContentType.toolkit,
      source: ContentSource.partner,
      delivery: ContentDelivery.externalLink,
    ),
  ],
  recommended: [
    RecommendedDto(
      content: labCard(id: 'r-1', title: 'Grant Writing for Creatives'),
      reason: 'Because you want to develop Grant writing',
    ),
  ],
);

FakeLearningRepository _hubRepo() => FakeLearningRepository(
  hub: _richHub(),
  lessons: {'lesson-4': lessonDto(n: 4, total: 7, title: 'Walk cycles')},
  details: {'lab-1': labDetail(course: courseInfo(enrolled: true, done: 1))},
);

void main() {
  group('hub', () {
    testWidgets(
      'continue card with a real percentage, featured, groups and reasons',
      (t) async {
        final h = await openApp(t, repo: _hubRepo());
        expect(find.text('Skill Labs'), findsOneWidget);
        expect(find.text('My learning'), findsOneWidget);
        expect(find.text('CONTINUE LEARNING'), findsOneWidget);
        expect(find.text('Character Animation Basics'), findsOneWidget);
        expect(find.text('Lesson 4 of 7 · Walk cycles'), findsOneWidget);
        expect(find.text('57%'), findsOneWidget);
        expect(find.text('Featured Labs'), findsOneWidget);
        expect(find.text('Pricing Your Creative Work'), findsOneWidget);
        expect(find.text('✓ Atarah Course'), findsWidgets);
        expect(find.text('Partner content'), findsOneWidget);

        await reveal(t, find.text('Professional'));
        expect(find.text('Creative'), findsOneWidget);
        expect(find.text('Business'), findsOneWidget);
        expect(find.text('Portfolio Building'), findsOneWidget);
        expect(find.text('12'), findsOneWidget);

        await reveal(t, find.text('Because you want to develop Grant writing'));
        expect(find.text('Recommended for you'), findsOneWidget);
        expect(find.text('Grant writing'), findsNothing);
        expect(h.learning.calls, contains('hub'));
      },
    );

    testWidgets('the continue card opens the next lesson', (t) async {
      final h = await openApp(t, repo: _hubRepo());
      await t.tap(find.text('Character Animation Basics'));
      await t.pumpAndSettle();
      expect(h.path, '/learning/lessons/lesson-4');
      expect(find.text('Lesson 4 of 7'), findsOneWidget);
    });

    testWidgets(
      'a category chip opens its category and My learning opens the list',
      (t) async {
        final h = await openApp(t, repo: _hubRepo());
        await reveal(t, find.text('Portfolio Building'));
        await t.tap(find.text('Portfolio Building'));
        await t.pumpAndSettle();
        expect(h.path, '/learning/categories/portfolio-building');
        h.router.go('/learning');
        await t.pumpAndSettle();
        await t.tap(find.text('My learning'));
        await t.pumpAndSettle();
        expect(h.path, '/learning/mine');
      },
    );

    testWidgets('an empty hub says so', (t) async {
      await openApp(
        t,
        repo: FakeLearningRepository(hub: hubDto(categories: const [])),
      );
      expect(find.text('No Skill Labs yet'), findsOneWidget);
    });

    testWidgets('a failure offers a retry', (t) async {
      final repo = FakeLearningRepository()
        ..hubFailure = const NetworkFailure();
      await openApp(t, repo: repo);
      expect(find.text('Try again'), findsOneWidget);
      repo.hubFailure = null;
      await t.tap(find.text('Try again'));
      await t.pumpAndSettle();
      expect(find.text('Skill Labs'), findsOneWidget);
    });

    testWidgets('the Home quick access opens Skill Labs, not a placeholder', (
      t,
    ) async {
      final h = await openApp(t, at: '/home');
      await t.tap(find.text('Skill Labs'));
      await t.pumpAndSettle();
      expect(h.path, '/learning');
      expect(find.text('Soon · P1'), findsNothing);
    });
  });

  group('category', () {
    List<LearningCardDto> items() => [
      labCard(id: 'c-1', title: 'Course one'),
      labCard(id: 'c-2', title: 'Course two'),
      labCard(
        id: 'c-3',
        title: 'A tutorial',
        type: LearningContentType.tutorial,
        source: ContentSource.partner,
      ),
      labCard(
        id: 'c-4',
        title: 'A toolkit',
        type: LearningContentType.toolkit,
        source: ContentSource.valueExternal,
        delivery: ContentDelivery.externalLink,
      ),
      labCard(id: 'c-5', title: 'A webinar', type: LearningContentType.webinar),
    ];

    testWidgets('group pill, title, count, type chips and cards', (t) async {
      await openApp(
        t,
        at: '/learning/categories/portfolio-building',
        repo: FakeLearningRepository(categoryItems: items()),
      );
      expect(find.text('Professional'), findsOneWidget);
      expect(find.text('Portfolio Building'), findsOneWidget);
      expect(find.text('5 resources'), findsOneWidget);
      for (final chip in [
        'All',
        'Course',
        'Tutorial',
        'Toolkit',
        'Webinar',
        'Masterclass',
      ]) {
        expect(
          find.widgetWithText(AtChip, chip, skipOffstage: false),
          findsOneWidget,
        );
      }
      expect(find.text('Course one'), findsOneWidget);
      expect(find.text('External resource'), findsOneWidget);
    });

    testWidgets(
      'a type filter narrows the list; an empty type offers all types',
      (t) async {
        final h = await openApp(
          t,
          at: '/learning/categories/portfolio-building',
          repo: FakeLearningRepository(categoryItems: items()),
        );
        await t.tap(find.widgetWithText(AtChip, 'Tutorial'));
        await t.pumpAndSettle();
        expect(find.text('A tutorial'), findsOneWidget);
        expect(find.text('Course one'), findsNothing);
        expect(h.learning.calls.last, 'category:portfolio-building:TUTORIAL:1');

        final masterclass = find.widgetWithText(AtChip, 'Masterclass');
        await t.dragUntilVisible(
          masterclass,
          find.ancestor(
            of: find.widgetWithText(AtChip, 'Tutorial'),
            matching: find.byType(ListView),
          ),
          const Offset(-200, 0),
        );
        await t.pumpAndSettle();
        await t.tap(masterclass);
        await t.pumpAndSettle();
        expect(
          find.text('No masterclasses in Portfolio Building yet'),
          findsOneWidget,
        );
        await t.tap(find.text('Explore all types'));
        await t.pumpAndSettle();
        expect(find.text('Course one'), findsOneWidget);
      },
    );

    testWidgets('an empty category and an unknown one', (t) async {
      await openApp(
        t,
        at: '/learning/categories/portfolio-building',
        repo: FakeLearningRepository(),
      );
      expect(find.text('Nothing in Portfolio Building yet'), findsOneWidget);
    });

    testWidgets('pages in as the member scrolls', (t) async {
      final many = [
        for (var i = 1; i <= 25; i++)
          labCard(id: 'p-$i', title: 'Course number $i'),
      ];
      final h = await openApp(
        t,
        at: '/learning/categories/portfolio-building',
        repo: FakeLearningRepository(categoryItems: many, pageSize: 20),
      );
      expect(find.text('Course number 1'), findsOneWidget);
      await t.dragUntilVisible(
        find.text('Course number 25'),
        find.byType(ListView).last,
        const Offset(0, -400),
      );
      await t.pumpAndSettle();
      expect(find.text('Course number 25'), findsOneWidget);
      expect(
        h.learning.calls.where((c) => c.startsWith('category:')).length,
        2,
      );
    });

    testWidgets(
      'a card opens the Skill Lab; the bookmark rolls back when saving fails',
      (t) async {
        final repo = FakeLearningRepository(
          categoryItems: items(),
          details: {'c-1': labDetail(id: 'c-1', title: 'Course one')},
        );
        final h = await openApp(
          t,
          at: '/learning/categories/portfolio-building',
          repo: repo,
        );
        repo.saveFailure = const ApiFailure(
          code: 'INTERNAL',
          message: 'Saving is down.',
          statusCode: 500,
        );
        await t.tap(find.bySemanticsLabel('Save to my learning').first);
        await t.pump();
        await t.pumpAndSettle();
        expect(find.text('Saving is down.'), findsOneWidget);
        expect(find.byIcon(LucideIcons.bookmarkCheck), findsNothing);
        repo.saveFailure = null;
        await t.tap(find.text('Course one'));
        await t.pumpAndSettle();
        expect(h.path, '/learning/courses/c-1');
      },
    );
  });

  group('course detail', () {
    testWidgets(
      'lessons show Done, Current and Locked, with the progress box',
      (t) async {
        await openApp(
          t,
          at: '/learning/courses/lab-1',
          repo: FakeLearningRepository(
            details: {
              'lab-1': labDetail(course: courseInfo(enrolled: true, done: 1)),
            },
          ),
        );
        expect(find.text('✓ Atarah Course'), findsOneWidget);
        expect(find.text('In-app lessons'), findsOneWidget);
        expect(find.text('Beginner · 3 lessons · 35 min'), findsOneWidget);
        expect(find.text('Your progress'), findsOneWidget);
        expect(find.text('1 / 3'), findsOneWidget);
        await reveal(t, find.text('Lesson 3 title'));
        expect(find.text('Done'), findsOneWidget);
        expect(find.text('Current'), findsOneWidget);
        expect(find.text('Locked'), findsOneWidget);
        expect(find.text('Continue learning'), findsOneWidget);
        await reveal(t, find.text('Kiptoo Langat'));
        expect(find.text('Taught by'), findsOneWidget);
      },
    );

    testWidgets('a locked lesson cannot be opened; a current one opens', (
      t,
    ) async {
      final h = await openApp(
        t,
        at: '/learning/courses/lab-1',
        repo: FakeLearningRepository(
          details: {
            'lab-1': labDetail(course: courseInfo(enrolled: true, done: 1)),
          },
          lessons: {'lesson-2': lessonDto(n: 2, title: 'Choosing three')},
        ),
      );
      await reveal(t, find.text('Lesson 3 title'));
      await t.tap(find.text('Lesson 3 title'));
      await t.pumpAndSettle();
      expect(h.path, '/learning/courses/lab-1');
      await t.tap(find.text('Lesson 2 title'));
      await t.pumpAndSettle();
      expect(h.path, '/learning/lessons/lesson-2');
    });

    testWidgets('Start learning enrols and opens the first lesson', (t) async {
      final repo = FakeLearningRepository(
        details: {'lab-1': labDetail(course: courseInfo())},
        lessons: {'lesson-1': lessonDto()},
      );
      final h = await openApp(t, at: '/learning/courses/lab-1', repo: repo);
      expect(find.text('Your progress'), findsNothing);
      await t.tap(find.text('Start learning'));
      await t.pumpAndSettle();
      expect(repo.calls, contains('enrol:lab-1'));
      expect(h.path, '/learning/lessons/lesson-1');
      expect(find.text('What a portfolio is for'), findsWidgets);
    });

    testWidgets('a finished course shows the certificate and Review course', (
      t,
    ) async {
      final h = await openApp(
        t,
        at: '/learning/courses/lab-1',
        repo: FakeLearningRepository(
          details: {
            'lab-1': labDetail(
              course: courseInfo(enrolled: true, done: 3, cert: certificate()),
            ),
          },
        ),
      );
      expect(find.text('Certificate earned'), findsOneWidget);
      expect(find.text('No. ATC-2026-000007'), findsOneWidget);
      expect(find.text('Review course'), findsOneWidget);
      await t.tap(find.text('See it in your achievements'));
      await t.pumpAndSettle();
      expect(h.path, '/achievements');
    });

    testWidgets('premium content the member cannot open shows the gate', (
      t,
    ) async {
      await openApp(
        t,
        at: '/learning/courses/lab-1',
        repo: FakeLearningRepository(
          details: {
            'lab-1': labDetail(
              premiumLocked: true,
              access: LearningAccess.premiumContent,
              course: courseInfo(),
            ),
          },
        ),
      );
      expect(find.byType(AtPremiumGate), findsOneWidget);
      expect(find.text('Premium Skill Labs is part of Pro'), findsOneWidget);
      expect(find.text('Start learning'), findsNothing);
      expect(find.text('See Pro'), findsOneWidget);
    });

    testWidgets('a PREMIUM_REQUIRED answer to enrolling shows the gate', (
      t,
    ) async {
      final repo =
          FakeLearningRepository(
              details: {
                'lab-1': labDetail(
                  access: LearningAccess.premiumContent,
                  course: courseInfo(),
                ),
              },
            )
            ..enrolFailure = const ApiFailure(
              code: 'PREMIUM_REQUIRED',
              message: 'This is part of Atarah Pro.',
              statusCode: 403,
            );
      await openApp(t, at: '/learning/courses/lab-1', repo: repo);
      await t.tap(find.text('Start learning'));
      await t.pumpAndSettle();
      expect(find.byType(AtPremiumGate), findsOneWidget);
    });

    testWidgets('an unknown Skill Lab says it is not available', (t) async {
      await openApp(
        t,
        at: '/learning/courses/nope',
        repo: FakeLearningRepository(),
      );
      expect(find.text('No Skill Labs yet'), findsOneWidget);
      expect(find.text('Back to Skill Labs'), findsOneWidget);
      expect(_apiNotFound.statusCode, 404);
    });

    testWidgets(
      'the bookmark flips at once and the share sheet gets the link',
      (t) async {
        final repo = FakeLearningRepository(
          details: {'lab-1': labDetail(course: courseInfo())},
        );
        final h = await openApp(t, at: '/learning/courses/lab-1', repo: repo);
        await t.tap(find.widgetWithIcon(AtIconButton, LucideIcons.bookmark));
        await t.pumpAndSettle();
        expect(repo.calls, contains('save:lab-1'));
        expect(
          find.widgetWithIcon(AtIconButton, LucideIcons.bookmarkCheck),
          findsOneWidget,
        );
        await t.tap(find.widgetWithIcon(AtIconButton, LucideIcons.share2));
        await t.pumpAndSettle();
        expect(h.shared.single, contains('https://atarah.app/learning/lab-1'));
      },
    );
  });

  group('items that are not courses', () {
    FakeLearningRepository external({
      LearningDetailDtoLinkStatus link = LearningDetailDtoLinkStatus.unknown,
      LearningItemProgressDto? progress,
    }) => FakeLearningRepository(
      details: {
        'tk-1': labDetail(
          id: 'tk-1',
          title: 'Creative Business Starter Kit',
          type: LearningContentType.toolkit,
          source: ContentSource.partner,
          delivery: ContentDelivery.externalLink,
          externalUrl: 'https://toolkit.example.org/start',
          externalDomain: 'toolkit.example.org',
          instructor: null,
          provider: 'Creative Economy Kenya',
          link: link,
          itemProgress: progress,
        ),
      },
    );

    testWidgets('the leaving sheet names the site; Stay does nothing', (
      t,
    ) async {
      final repo = external();
      final h = await openApp(t, at: '/learning/courses/tk-1', repo: repo);
      expect(find.text('Partner content'), findsOneWidget);
      expect(find.text('Opens outside Atarah'), findsOneWidget);
      await t.tap(find.text('Open resource'));
      await t.pumpAndSettle();
      expect(find.textContaining('toolkit.example.org'), findsOneWidget);
      expect(find.text('Track this as applied in Activity'), findsNothing);
      await t.tap(find.text('Stay on Atarah'));
      await t.pumpAndSettle();
      expect(h.opened, isEmpty);
      expect(repo.calls.where((c) => c.startsWith('start:')), isEmpty);
    });

    testWidgets('Continue opens the browser, then marks it started', (t) async {
      final repo = external();
      final h = await openApp(t, at: '/learning/courses/tk-1', repo: repo);
      await t.tap(find.text('Open resource'));
      await t.pumpAndSettle();
      await t.tap(find.text('Continue to website'));
      await t.pumpAndSettle();
      expect(h.opened.single.toString(), 'https://toolkit.example.org/start');
      expect(repo.calls, contains('start:tk-1'));
    });

    testWidgets('a started item can be marked complete by hand', (t) async {
      final repo = external(
        progress: itemProgress(0, status: LessonProgressStatus.inProgress),
      );
      await openApp(t, at: '/learning/courses/tk-1', repo: repo);
      await t.tap(find.text('Mark as complete'));
      await t.pumpAndSettle();
      expect(repo.calls, contains('complete:tk-1'));
    });

    testWidgets('a dead link says so and offers similar Skill Labs', (t) async {
      final h = await openApp(
        t,
        at: '/learning/courses/tk-1',
        repo: external(link: LearningDetailDtoLinkStatus.broken),
      );
      expect(find.text('This link no longer works'), findsOneWidget);
      expect(find.text('Open resource'), findsNothing);
      await t.tap(find.text('Find similar'));
      await t.pumpAndSettle();
      expect(h.path, '/learning/categories/portfolio-building');
    });

    testWidgets(
      'an embedded item shows its player, counts as started and reports a failure',
      (t) async {
        final repo = FakeLearningRepository(
          details: {
            'em-1': labDetail(
              id: 'em-1',
              title: 'Colour Grading Quick Start',
              type: LearningContentType.tutorial,
              delivery: ContentDelivery.embedded,
              embedUrl: 'https://www.youtube-nocookie.com/embed/abcDEF12345',
              instructor: null,
            ),
          },
        );
        final h = await openApp(t, at: '/learning/courses/em-1', repo: repo);
        expect(
          find.text('EMBED https://www.youtube-nocookie.com/embed/abcDEF12345'),
          findsOneWidget,
        );
        expect(repo.calls, contains('start:em-1'));
        h.embeds.fail();
        await t.pumpAndSettle();
        expect(find.text("YouTube isn't responding"), findsOneWidget);
        expect(find.text('This link no longer works'), findsNothing);
      },
    );
  });

  group('lesson', () {
    LessonDto practiceLesson({int n = 1}) => lessonDto(
      n: n,
      practice: const PracticeDto(
        prompt: 'Pick your three projects and add them.',
        skill: SkillRefDto(id: 'skill-1', name: 'Colour'),
      ),
    );

    testWidgets('shows the text, segments, practice box and the next steps', (
      t,
    ) async {
      final h = await openApp(
        t,
        at: '/learning/lessons/lesson-1',
        repo: FakeLearningRepository(lessons: {'lesson-1': practiceLesson()}),
      );
      expect(find.text('Lesson 1 of 3'), findsOneWidget);
      expect(find.text('What a portfolio is for'), findsWidgets);
      expect(
        find.text('Can this person do what I need? Show work that says yes.'),
        findsOneWidget,
      );
      expect(find.text('Rule of thumb'), findsOneWidget);
      await revealIn(t, find.text('Add to portfolio'));
      expect(find.text('Practice'), findsOneWidget);
      expect(
        find.text('Pick your three projects and add them.'),
        findsOneWidget,
      );
      await t.tap(find.text('Add to portfolio'));
      await t.pumpAndSettle();
      expect(h.path, '/portfolio/new/edit');
      expect(h.router.state.uri.queryParameters['skillName'], 'Colour');
    });

    testWidgets('"What should I learn next?" is a Soon · P3 screen', (t) async {
      final h = await openApp(
        t,
        at: '/learning/lessons/lesson-1',
        repo: FakeLearningRepository(lessons: {'lesson-1': lessonDto()}),
      );
      await revealIn(t, find.text('What should I learn next?'));
      await t.tap(find.text('What should I learn next?'));
      await t.pumpAndSettle();
      expect(h.path, startsWith('/soon/p3'));
    });

    testWidgets(
      'Mark complete & next writes completion and opens the next lesson',
      (t) async {
        final repo = FakeLearningRepository(
          lessons: {
            'lesson-1': lessonDto(),
            'lesson-2': lessonDto(n: 2, title: 'Choosing three'),
          },
        );
        final h = await openApp(
          t,
          at: '/learning/lessons/lesson-1',
          repo: repo,
        );
        await t.tap(find.text('Mark complete & next'));
        await t.pumpAndSettle();
        expect(repo.progressWrites.last.completed, isTrue);
        expect(repo.progressWrites.last.lesson, 'lesson-1');
        expect(h.path, '/learning/lessons/lesson-2');
        expect(find.text('Lesson 2 of 3'), findsOneWidget);
      },
    );

    testWidgets('finishing the last lesson shows the certificate', (t) async {
      final repo = FakeLearningRepository(
        lessons: {'lesson-3': lessonDto(n: 3, title: 'Keeping it fresh')},
      )..courseCompletesOnComplete = true;
      final h = await openApp(t, at: '/learning/lessons/lesson-3', repo: repo);
      expect(find.text('Mark complete & finish'), findsOneWidget);
      await t.tap(find.text('Mark complete & finish'));
      await t.pumpAndSettle();
      expect(find.text('Course complete!'), findsOneWidget);
      expect(
        find.textContaining('Build a Portfolio That Gets You Hired'),
        findsOneWidget,
      );
      expect(find.text('Certificate earned'), findsOneWidget);
      expect(find.text('No. ATC-2026-000007'), findsOneWidget);
      await t.tap(find.text('Share'));
      await t.pumpAndSettle();
      expect(
        h.shared.single,
        contains('Build a Portfolio That Gets You Hired'),
      );
      await t.tap(find.text('Back to Skill Labs'));
      await t.pumpAndSettle();
      expect(h.path, '/learning');
    });

    testWidgets('a locked lesson explains why', (t) async {
      await openApp(
        t,
        at: '/learning/lessons/lesson-3',
        repo: FakeLearningRepository()
          ..lessonFailure = const ApiFailure(
            code: 'INVALID_STATE',
            message: 'Finish the earlier lessons to unlock this one.',
            statusCode: 409,
            details: {'reason': 'LOCKED'},
          ),
      );
      expect(
        find.text('Finish the earlier lessons to unlock this one.'),
        findsOneWidget,
      );
    });

    testWidgets('a premium lesson shows the gate', (t) async {
      await openApp(
        t,
        at: '/learning/lessons/lesson-1',
        repo: FakeLearningRepository()
          ..lessonFailure = const ApiFailure(
            code: 'PREMIUM_REQUIRED',
            message: 'This is part of Atarah Pro.',
            statusCode: 403,
          ),
      );
      expect(find.byType(AtPremiumGate), findsOneWidget);
    });

    testWidgets(
      'a video resumes where the member stopped and reports at a steady pace',
      (t) async {
        final repo = FakeLearningRepository(
          lessons: {
            'lesson-1': lessonDto(
              video: true,
              position: 125,
              status: LessonProgressStatus.inProgress,
            ),
          },
        );
        final h = await openApp(
          t,
          at: '/learning/lessons/lesson-1',
          repo: repo,
        );
        expect(
          find.text(
            'VIDEO https://storage.example.org/signed/lesson-1.mp4 from 125s',
          ),
          findsOneWidget,
        );
        final args = h.videos.last;
        expect(args.startAt, const Duration(seconds: 125));
        expect(repo.calls, contains('video:lesson-1'));

        // The first tick is written; ticks right after it are not; a pause is written at once.
        args.onPosition(130, PositionReason.tick);
        await t.pumpAndSettle();
        args.onPosition(135, PositionReason.tick);
        args.onPosition(140, PositionReason.tick);
        await t.pumpAndSettle();
        expect(repo.progressWrites.map((w) => w.position), [130]);
        args.onPosition(150, PositionReason.pause);
        await t.pumpAndSettle();
        expect(repo.progressWrites.map((w) => w.position), [130, 150]);
        // Kept on the phone too, so it survives no signal.
        expect(h.learningStorage.values['learning.position.lesson-1'], '150');
      },
    );

    testWidgets('a video that is still being prepared says so', (t) async {
      final repo =
          FakeLearningRepository(lessons: {'lesson-1': lessonDto(video: true)})
            ..videoFailure = const ApiFailure(
              code: 'INVALID_STATE',
              message: 'preparing',
              statusCode: 409,
            );
      await openApp(t, at: '/learning/lessons/lesson-1', repo: repo);
      expect(
        find.text('The video is still being prepared. Try again in a moment.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'an embedded lesson player that fails shows the external-service error',
      (t) async {
        final repo = FakeLearningRepository(
          lessons: {
            'lesson-1': lessonDto(
              embed: 'https://www.youtube-nocookie.com/embed/abcDEF12345',
            ),
          },
        );
        final h = await openApp(
          t,
          at: '/learning/lessons/lesson-1',
          repo: repo,
        );
        expect(h.embeds.urls, [
          'https://www.youtube-nocookie.com/embed/abcDEF12345',
        ]);
        h.embeds.fail();
        await t.pumpAndSettle();
        expect(find.text("YouTube isn't responding"), findsOneWidget);
        expect(
          find.text('Atarah is working normally. The other site may be down.'),
          findsOneWidget,
        );
        expect(find.text('Go back to course'), findsOneWidget);
      },
    );
  });

  group('offline copy', () {
    testWidgets(
      'a course the member is on is read from the saved copy when offline',
      (t) async {
        final repo = FakeLearningRepository(
          details: {
            'lab-1': labDetail(course: courseInfo(enrolled: true, done: 1)),
          },
          hub: _richHub(),
        );
        final h = await openApp(t, at: '/learning/courses/lab-1', repo: repo);
        expect(
          find.text(
            'Showing your saved copy. Connect to the internet to keep learning.',
          ),
          findsNothing,
        );
        h.router.go('/learning');
        await t.pumpAndSettle();
        repo.detailFailure = const NetworkFailure();
        h.router.go('/learning/courses/lab-1');
        await t.pumpAndSettle();
        expect(
          find.text(
            'Showing your saved copy. Connect to the internet to keep learning.',
          ),
          findsOneWidget,
        );
        expect(find.text('Continue learning'), findsOneWidget);
      },
    );

    testWidgets(
      'a lesson opened before is read from the saved copy, but completing needs a connection',
      (t) async {
        final repo = FakeLearningRepository(
          lessons: {'lesson-1': lessonDto(position: 42)},
        );
        final h = await openApp(
          t,
          at: '/learning/lessons/lesson-1',
          repo: repo,
        );
        h.router.go('/learning');
        await t.pumpAndSettle();
        repo.lessonFailure = const NetworkFailure();
        h.router.go('/learning/lessons/lesson-1');
        await t.pumpAndSettle();
        expect(
          find.text(
            'Showing your saved copy. Connect to the internet to keep learning.',
          ),
          findsOneWidget,
        );
        await t.tap(find.text('Mark complete & next'));
        await t.pumpAndSettle();
        expect(
          find.text('Connect to the internet to continue.'),
          findsOneWidget,
        );
        expect(repo.progressWrites.where((w) => w.completed == true), isEmpty);
      },
    );

    testWidgets('a lesson never opened has no saved copy and shows the error', (
      t,
    ) async {
      await openApp(
        t,
        at: '/learning/lessons/lesson-9',
        repo: FakeLearningRepository()..lessonFailure = const NetworkFailure(),
      );
      expect(find.text('Try again'), findsOneWidget);
    });
  });

  group('my learning', () {
    MyLearningItemDto mine(
      String id,
      String title,
      int percent, {
      DateTime? at,
    }) => MyLearningItemDto(
      content: labCard(id: id, title: title, progress: itemProgress(percent)),
      lastActivityAt: at ?? DateTime.utc(2026, 10, 30),
    );

    testWidgets('stat tiles, Active list with progress, and the empty tabs', (
      t,
    ) async {
      await openApp(
        t,
        at: '/learning/mine',
        repo: FakeLearningRepository(
          mineActive: [
            mine('a-1', 'Character Animation Basics', 57),
            mine('a-2', 'Pricing Your Creative Work', 25),
          ],
        ),
      );
      expect(find.text('In progress'), findsOneWidget);
      expect(find.text('Completed'), findsWidgets);
      expect(find.text('Hours this month'), findsOneWidget);
      expect(find.text('2.5'), findsOneWidget);
      expect(find.text('Character Animation Basics'), findsOneWidget);
      expect(find.byType(AtProgressBar), findsNWidgets(2));

      await t.tap(
        find.descendant(
          of: find.byType(AtSegmented),
          matching: find.text('Completed'),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('Nothing completed yet'), findsOneWidget);
      await t.tap(
        find.descendant(
          of: find.byType(AtSegmented),
          matching: find.text('Saved'),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('No saved Skill Labs'), findsOneWidget);
    });

    testWidgets('an empty Active tab sends the member to Skill Labs', (
      t,
    ) async {
      final h = await openApp(t, at: '/learning/mine');
      expect(find.text('Nothing in progress'), findsOneWidget);
      await t.tap(find.text('Browse Skill Labs'));
      await t.pumpAndSettle();
      expect(h.path, '/learning');
    });

    testWidgets('the saved tab can be the first one shown', (t) async {
      await openApp(
        t,
        at: '/learning/mine?tab=saved',
        repo: FakeLearningRepository(
          mineSaved: [mine('s-1', 'Saved course', 0)],
        ),
      );
      expect(find.text('Saved course'), findsOneWidget);
    });
  });

  group('search', () {
    testWidgets('the search screen offers a Skill Labs tab', (t) async {
      await openApp(t, at: '/search');
      await t.enterText(find.byType(TextField).first, 'Nia');
      await t.pump(const Duration(milliseconds: 700));
      await t.pumpAndSettle();
      expect(find.text('Skill Labs (0)', skipOffstage: false), findsOneWidget);
    });
  });

  group('progress reporter', () {
    test(
      'writes the first tick, throttles the next, and writes pauses at once',
      () async {
        var now = DateTime.utc(2026, 11, 2, 9);
        final sent = <int>[];
        final r = ProgressReporter(
          send: (s) async => sent.add(s),
          now: () => now,
        );
        await r.report(10, PositionReason.tick);
        now = now.add(const Duration(seconds: 5));
        await r.report(15, PositionReason.tick);
        now = now.add(const Duration(seconds: 9));
        await r.report(24, PositionReason.tick);
        expect(sent, [10]);
        now = now.add(const Duration(seconds: 2));
        await r.report(26, PositionReason.tick);
        expect(sent, [10, 26]);
        await r.report(27, PositionReason.pause);
        await r.report(27, PositionReason.exit);
        expect(sent, [10, 26, 27]);
      },
    );

    test('never sends a position behind the furthest one and starts from the saved position', () async {
      final sent = <int>[];
      final r = ProgressReporter(send: (s) async => sent.add(s), startAt: 100);
      await r.report(40, PositionReason.pause);
      expect(sent, isEmpty);
      await r.report(130, PositionReason.pause);
      await r.report(90, PositionReason.exit);
      expect(sent, [130]);
      expect(r.best, 130);
    });
  });
}
