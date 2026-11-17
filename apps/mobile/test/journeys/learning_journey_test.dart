import 'package:atarah/features/learning/lesson_players.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/fake_learning.dart';
import '../support/fakes.dart';

/// P1-M12 journey (c), fake-backed: Skill Labs hub, a course, its first lesson, leaving and resuming a video
/// where it stopped, completing every lesson and earning the certificate. Real-backend twin:
/// `integration_test/journey_learning_test.dart` (written, not run: no emulator).
void main() {
  testWidgets('hub, course, lesson, resume, complete, certificate', (t) async {
    final repo = FakeLearningRepository(
      hub: hubDto(
        featured: [
          labCard(
            id: 'lab-1',
            title: 'Build a Portfolio That Gets You Hired',
            featured: true,
          ),
        ],
      ),
      details: {'lab-1': labDetail(course: courseInfo())},
      lessons: {
        'lesson-1': lessonDto(video: true),
        'lesson-2': lessonDto(n: 2, title: 'Choosing three'),
        'lesson-3': lessonDto(n: 3, title: 'Keeping it fresh'),
      },
    );
    final h = Harness(
      auth: FakeAuthRepository(restored: fakeUser(name: 'Nia Wairimu')),
      learning: repo,
    );
    await h.pump(t);

    // Hub -> course.
    h.router.go('/learning');
    await t.pumpAndSettle();
    expect(find.text('Skill Labs'), findsOneWidget);
    await tapText(t, 'Build a Portfolio That Gets You Hired');
    expect(h.path, '/learning/courses/lab-1');

    // Course -> first lesson (enrols).
    await tapText(t, 'Start learning');
    expect(repo.calls, contains('enrol:lab-1'));
    expect(h.path, '/learning/lessons/lesson-1');
    expect(find.text('Lesson 1 of 3'), findsOneWidget);

    // Watch a little, then leave mid-lesson.
    h.videos.last.onPosition(150, PositionReason.pause);
    await t.pumpAndSettle();
    expect(repo.progressWrites.last.position, 150);
    h.router.go('/learning/courses/lab-1');
    await t.pumpAndSettle();

    // Resume: the lesson reopens where the member stopped (kept on the phone and on the server).
    h.router.go('/learning/lessons/lesson-1');
    await t.pumpAndSettle();
    expect(h.videos.last.startAt, const Duration(seconds: 150));

    // Complete each lesson in turn; the last one earns the certificate.
    await tapText(t, 'Mark complete & next');
    expect(h.path, '/learning/lessons/lesson-2');
    await tapText(t, 'Mark complete & next');
    expect(h.path, '/learning/lessons/lesson-3');
    repo.courseCompletesOnComplete = true;
    await tapText(t, 'Mark complete & finish');
    expect(find.text('Course complete!'), findsOneWidget);
    expect(find.text('Certificate earned'), findsOneWidget);
    expect(find.text('No. ATC-2026-000007'), findsOneWidget);
    expect(
      repo.progressWrites
          .where((w) => w.completed == true)
          .map((w) => w.lesson),
      ['lesson-1', 'lesson-2', 'lesson-3'],
    );
    await tapText(t, 'Back to Skill Labs');
    expect(h.path, '/learning');
    expect(t.takeException(), isNull);
  });
}
