import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/journey_support.dart';

/// P1-M12 journey (c) on a real emulator against the real local backend (dev demo seed): Skill Labs hub, a
/// course, its first lesson, leaving and resuming, completing every lesson, the certificate. NOT RUN: no
/// emulator was available when this was written. Fake-backed twin that does run:
/// `test/journeys/learning_journey_test.dart`.
///
/// "Build a Portfolio That Gets You Hired" is the five-lesson course the dev demo seed creates.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late final JourneyEnv env;
  setUpAll(() async => env = await JourneyEnv.start());

  final stamp = DateTime.now().millisecondsSinceEpoch;
  const course = 'Build a Portfolio That Gets You Hired';

  testWidgets('hub, course, lesson, resume, complete, certificate', (t) async {
    await registerAndSetUp(
      t,
      env,
      email: 'learn.$stamp@demo.atarah.test',
      name: 'Learning Tester',
      handle: 'learn_$stamp',
    );

    // Hub to course.
    await goTo(t, '/learning');
    expect(find.text('Skill Labs'), findsOneWidget);
    await reveal(t, find.text(course));
    await tapLabel(t, course, wait: 4);

    // Course to the first lesson.
    await tapLabel(t, 'Start learning', wait: 4);
    expect(find.text('Lesson 1 of 5'), findsOneWidget);

    // Leave mid-lesson and resume from the course page ("Continue learning").
    await goTo(t, '/learning');
    await reveal(t, find.text(course));
    await tapLabel(t, course, wait: 4);
    await tapLabel(t, 'Continue learning', wait: 4);
    expect(find.text('Lesson 1 of 5'), findsOneWidget);

    // Complete lessons 1 to 4, then finish the last one.
    for (var n = 1; n <= 4; n++) {
      await tapLabel(t, 'Mark complete & next', wait: 4);
      expect(find.text('Lesson ${n + 1} of 5'), findsOneWidget);
    }
    await tapLabel(t, 'Mark complete & finish', wait: 5);
    expect(find.text('Course complete!'), findsOneWidget);
    expect(find.text('Certificate earned'), findsOneWidget);
    expect(find.textContaining('No. ATC-'), findsOneWidget);
  });
}
