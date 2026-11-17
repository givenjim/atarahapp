import 'package:atarah/core/api/generated/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/fake_discover.dart';
import '../support/fake_opportunities.dart';
import '../support/fakes.dart';

/// Scrolls the detail page (the one with the pull-to-refresh) until [finder] is on screen.
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

/// P1-M12 journey (b), fake-backed: search, open the detail, read the profile-gap card, save, leave Atarah to
/// apply, see "applied", then complete with an outcome. Real-backend twin:
/// `integration_test/journey_opportunity_test.dart` (written, not run: no emulator).
void main() {
  testWidgets('search, detail, gap card, save, leave, applied, completed', (
    t,
  ) async {
    final opportunities = FakeOpportunitiesRepository(
      opportunities: [
        oppDto(
          gap: gapOf([
            rule(),
            rule(
              id: 'r-2',
              type: OpportunityRuleType.skillIn,
              label: 'A relevant skill',
              detail: 'You have 0 of 2 of these skills.',
              fix: const RuleFixDto(label: 'Add', path: '/skills'),
            ),
          ]),
        ),
      ],
    );
    final discover = FakeDiscoverRepository(
      opportunityHits: [opportunityHit('o-1', 'Emerging Creatives Grant 2027')],
    );
    final h = Harness(
      auth: FakeAuthRepository(restored: fakeUser(name: 'Nia Wairimu')),
      opportunities: opportunities,
      discover: discover,
    );
    await h.pump(t);

    // Search from the Opportunities tab.
    h.router.go('/opportunities');
    await t.pumpAndSettle();
    await t.tap(find.bySemanticsLabel('Search grants, gigs, jobs…'));
    await t.pumpAndSettle();
    expect(h.path, '/search');
    await t.enterText(find.byType(TextField), 'emerging');
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle();
    expect(find.text('Emerging Creatives Grant 2027'), findsOneWidget);
    await tapText(t, 'Emerging Creatives Grant 2027');
    expect(h.path, '/opportunities/o-1');
    expect(discover.recorded, ['emerging']);

    // The gap card says what is missing before the member applies.
    await reveal(t, find.textContaining('Your profile is missing'));
    expect(find.text('Add them before you apply'), findsOneWidget);

    // Save.
    await t.tap(find.bySemanticsLabel('Save Emerging Creatives Grant 2027'));
    await t.pumpAndSettle();
    expect(opportunities.calls, contains('save:o-1'));
    expect(
      find.bySemanticsLabel('Remove from saved: Emerging Creatives Grant 2027'),
      findsOneWidget,
    );

    // Leave Atarah to apply; the member asked to track it, so it becomes applied.
    await t.tap(find.text('Apply on external website'));
    await t.pumpAndSettle();
    expect(find.text("You're leaving Atarah"), findsOneWidget);
    await t.tap(find.text('Continue to website'));
    await t.pumpAndSettle();
    expect(h.opened.single.toString(), 'https://funds.example.org/apply');
    expect(opportunities.calls, contains('track:o-1:APPLIED'));

    // Applied shows in My opportunities, where it can be completed.
    h.router.go('/opportunities/mine?tab=applied');
    await t.pumpAndSettle();
    expect(find.text('Emerging Creatives Grant 2027'), findsOneWidget);

    // Completed, with an outcome.
    await tapText(t, 'Mark as completed');
    await tapText(t, 'Withdrawn');
    await tapText(t, 'Save outcome');
    expect(opportunities.calls, contains('track:o-1:COMPLETED:WITHDRAWN'));
    await tapText(t, 'Completed');
    expect(find.text('Completed · Withdrawn'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
