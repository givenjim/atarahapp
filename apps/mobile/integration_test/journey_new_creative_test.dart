import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/journey_support.dart';

/// P1-M12 journey (a) on a real emulator against the real local backend: sign up, verify, onboarding, Home,
/// add a project, open the public profile. NOT RUN: no emulator was available when this was written (see
/// docs/PROGRESS.md, P1-M12). Fake-backed twin that does run: `test/journeys/new_creative_journey_test.dart`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late final JourneyEnv env;
  setUpAll(() async => env = await JourneyEnv.start());

  final stamp = DateTime.now().millisecondsSinceEpoch;
  final email = 'creative.$stamp@demo.atarah.test';
  final handle = 'new_$stamp';

  testWidgets(
    'sign up, verify, onboarding, home, add project, public profile',
    (t) async {
      await registerAndSetUp(
        t,
        env,
        email: email,
        name: 'Journey Creative',
        handle: handle,
      );
      expect(find.text('Welcome, Journey'), findsOneWidget);

      // Add a project and publish it.
      await goTo(t, '/portfolio/new/edit');
      await t.enterText(
        find.descendant(
          of: find.byWidgetPredicate(
            (w) => w is AtTextField && w.label == 'Title',
          ),
          matching: find.byType(TextField),
        ),
        'Mama Mboga',
      );
      await tapLabel(t, 'Publish', wait: 4);
      expect(find.text('Mama Mboga'), findsOneWidget);

      // The public profile shows the member and the published project.
      await goTo(t, Routes.creativePath(handle, preview: true));
      expect(find.text('Journey Creative'), findsWidgets);
      expect(
        find.text('This is how your profile looks to others.'),
        findsOneWidget,
      );
    },
  );
}
