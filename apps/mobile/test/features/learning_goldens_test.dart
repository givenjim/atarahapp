import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/fake_learning.dart';
import '../support/fakes.dart';

/// Skill Labs hub, category, course detail, lesson, completion and My learning, in both appearances, 390x844 at 1x.
/// Regenerate after intentional visual changes:
/// `flutter test --update-goldens test/features/learning_goldens_test.dart`.
void main() {
  for (final appearance in AtAppearance.values) {
    final dark = appearance == AtAppearance.dark;

    FakeLearningRepository repo({bool finishing = false}) =>
        FakeLearningRepository(
          hub: hubDto(
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
              labCard(
                id: 'f-1',
                title: 'Pricing Your Creative Work',
                featured: true,
              ),
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
                content: labCard(
                  id: 'r-1',
                  title: 'Grant Writing for Creatives',
                  access: LearningAccess.premiumContent,
                  premiumLocked: true,
                ),
                reason: 'Because you want to develop Grant writing',
              ),
            ],
          ),
          categoryItems: [
            labCard(
              id: 'c-1',
              title: 'Build a Portfolio That Gets You Hired',
              progress: itemProgress(40),
              saved: true,
            ),
            labCard(
              id: 'c-2',
              title: 'Writing About Your Work',
              type: LearningContentType.tutorial,
              source: ContentSource.partner,
              level: SkillLevel.intermediate,
              minutes: 18,
            ),
            labCard(
              id: 'c-3',
              title: 'Portfolio Review Toolkit',
              type: LearningContentType.toolkit,
              source: ContentSource.valueExternal,
              delivery: ContentDelivery.externalLink,
              minutes: 20,
            ),
          ],
          details: {
            'lab-1': labDetail(course: courseInfo(enrolled: true, done: 1)),
          },
          lessons: {
            'lesson-1': lessonDto(
              practice: const PracticeDto(
                prompt: 'List every project you could show. Circle the three that look most like the work you want next.',
                skill: SkillRefDto(id: 'skill-1', name: 'Colour'),
              ),
            ),
            'lesson-3': lessonDto(
              n: 3,
              title: 'Keeping it fresh',
              segments: const [true, true, false],
            ),
          },
          mineActive: [
            MyLearningItemDto(
              content: labCard(
                id: 'a-1',
                title: 'Character Animation Basics',
                progress: itemProgress(57),
              ),
              lastActivityAt: DateTime.utc(2026, 10, 30),
            ),
            MyLearningItemDto(
              content: labCard(
                id: 'a-2',
                title: 'Pricing Your Creative Work',
                progress: itemProgress(25),
              ),
              lastActivityAt: DateTime.utc(2026, 10, 28),
            ),
          ],
        )..courseCompletesOnComplete = finishing;

    Future<Harness> open(
      WidgetTester t,
      String at, {
      bool finishing = false,
    }) async {
      final h = Harness(
        appearance: appearance,
        auth: FakeAuthRepository(
          restored: fakeUser(
            name: 'Nia Wairimu',
            appearance: dark ? MeDtoAppearance.dark : MeDtoAppearance.light,
          ),
        ),
        learning: repo(finishing: finishing),
      );
      await h.pump(t);
      h.router.go(at);
      await t.pumpAndSettle();
      return h;
    }

    Future<void> shoot(WidgetTester t, String name) => expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/screens/$name.${appearance.name}.png'),
    );

    testWidgets('learning hub ${appearance.name}', (t) async {
      await open(t, '/learning');
      await shoot(t, 'learning_hub');
    });

    testWidgets('learning category ${appearance.name}', (t) async {
      await open(t, '/learning/categories/portfolio-building');
      await shoot(t, 'learning_category');
    });

    testWidgets('course detail ${appearance.name}', (t) async {
      await open(t, '/learning/courses/lab-1');
      await shoot(t, 'learning_course');
    });

    testWidgets('lesson ${appearance.name}', (t) async {
      await open(t, '/learning/lessons/lesson-1');
      await shoot(t, 'learning_lesson');
    });

    testWidgets('course complete ${appearance.name}', (t) async {
      await open(t, '/learning/lessons/lesson-3', finishing: true);
      await t.tap(find.text('Mark complete & finish'));
      await t.pumpAndSettle();
      await shoot(t, 'learning_complete');
    });

    testWidgets('my learning ${appearance.name}', (t) async {
      await open(t, '/learning/mine');
      await shoot(t, 'learning_mine');
    });
  }
}
