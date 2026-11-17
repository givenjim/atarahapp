import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/journey_support.dart';

/// P1-M12 journey (b) on a real emulator against the real local backend (dev demo seed): search, detail, the
/// profile-gap card, save, leave Atarah to apply, applied, completed. NOT RUN: no emulator was available when
/// this was written. Fake-backed twin that does run: `test/journeys/opportunity_journey_test.dart`.
///
/// The grant is the one the dev demo seed creates; the external site is not opened (the journey records the
/// address the app would open).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late final JourneyEnv env;
  setUpAll(() async => env = await JourneyEnv.start());

  final stamp = DateTime.now().millisecondsSinceEpoch;
  const title = 'Emerging Creatives Grant 2027';

  testWidgets('search, detail, gap card, save, leave, applied, completed', (
    t,
  ) async {
    await registerAndSetUp(
      t,
      env,
      email: 'opp.$stamp@demo.atarah.test',
      name: 'Opportunity Tester',
      handle: 'opp_$stamp',
    );

    // Search from the Opportunities tab.
    await goTo(t, '/opportunities');
    await t.tap(find.bySemanticsLabel('Search grants, gigs, jobs…'));
    await settle(t);
    await t.enterText(find.byType(TextField), 'Emerging');
    await settle(t, seconds: 3);
    expect(find.text(title), findsWidgets);
    await tapLabel(t, title, wait: 4);

    // The gap card: a brand-new member does not meet every requirement, and the card says so.
    await reveal(t, find.textContaining('Your profile'));
    expect(find.textContaining('Your profile'), findsWidgets);

    // Save.
    await t.tap(find.bySemanticsLabel('Save $title'));
    await settle(t, seconds: 3);
    expect(find.bySemanticsLabel('Remove from saved: $title'), findsOneWidget);

    // Leave Atarah to apply, and ask Atarah to track it as applied.
    await t.scrollUntilVisible(
      find.text('Apply on external website'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tapLabel(t, 'Apply on external website');
    expect(find.text("You're leaving Atarah"), findsOneWidget);
    await tapLabel(t, 'Continue to website', wait: 4);
    expect(env.opened, isNotEmpty);

    // It is now applied; complete it from My opportunities.
    await goTo(t, '/opportunities/mine');
    await tapLabel(t, 'Applied');
    expect(find.text(title), findsOneWidget);
    await tapLabel(t, 'Mark as completed');
    await tapLabel(t, 'Withdrawn');
    await tapLabel(t, 'Save outcome', wait: 4);
    await tapLabel(t, 'Completed');
    expect(find.text('Completed · Withdrawn'), findsOneWidget);
  });
}
