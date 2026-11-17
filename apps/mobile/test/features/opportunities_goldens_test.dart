import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/fake_opportunities.dart';
import '../support/fakes.dart';

/// Opportunities home, list, detail (with the profile check), the leaving modal and My opportunities, in both
/// appearances, 390x844 at 1x. Regenerate after intentional visual changes:
/// `flutter test --update-goldens test/features/opportunities_goldens_test.dart`.
void main() {
  for (final appearance in AtAppearance.values) {
    final dark = appearance == AtAppearance.dark;

    FakeOpportunitiesRepository repo() => FakeOpportunitiesRepository(
      opportunities: [
        oppDto(
          id: 'o-1',
          title: 'Emerging Creatives Grant 2027',
          featured: true,
          daysLeft: 9,
          urgency: OpportunityDtoUrgency.urgent,
          gap: gapOf([
            rule(),
            rule(
              id: 'r-2',
              type: OpportunityRuleType.skillIn,
              label: 'A relevant skill',
              detail: 'You have 0 of 2 of these skills.',
              fix: const RuleFixDto(label: 'Add', path: '/skills'),
            ),
            rule(
              id: 'r-3',
              type: OpportunityRuleType.residency,
              label: 'Based in Kenya',
              state: RuleResultDtoState.met,
              detail: null,
              fix: null,
            ),
            rule(
              id: 'r-4',
              type: OpportunityRuleType.document,
              label: 'Artist statement',
              state: RuleResultDtoState.unknown,
              detail: 'Artist statement needed. Documents arrive soon.',
              fix: const RuleFixDto(
                label: 'Soon',
                path: '/soon/p2?name=Artist%20statement',
              ),
            ),
          ]),
        ),
        oppDto(
          id: 'o-2',
          title: 'Short Film Development Fund',
          type: OpportunityType.funding,
          trust: OpportunityTrust.sourceConfirmed,
          by: provider(
            id: 'p-2',
            name: 'Lakeside Film Collective',
            verified: false,
          ),
          value: 'KES 100,000 to 250,000',
          daysLeft: 12,
          urgency: OpportunityDtoUrgency.soon,
          county: 'Kisumu',
        ),
        oppDto(
          id: 'o-3',
          title: 'Junior Motion Designer',
          type: OpportunityType.job,
          trust: OpportunityTrust.externalSource,
          by: provider(
            id: 'p-3',
            name: 'East Africa Design Week',
            verified: false,
          ),
          value: 'KES 70,000 a month',
          daysLeft: 40,
          county: 'Nairobi',
        ),
        oppDto(
          id: 'o-4',
          title: 'Explainer video for a fintech launch',
          type: OpportunityType.gig,
          trust: OpportunityTrust.externalSource,
          by: provider(id: 'p-4', name: 'Pesa Labs', verified: false),
          value: 'KES 60,000 to 90,000',
          daysLeft: null,
          county: 'Remote',
        ),
      ],
      trackings: {
        'o-2': trackingOf(OpportunityTrackingStatus.saved),
        'o-3': trackingOf(OpportunityTrackingStatus.applied),
        'o-4': trackingOf(
          OpportunityTrackingStatus.completed,
          outcome: OpportunityOutcome.notSelected,
        ),
      },
    );

    Future<Harness> open(WidgetTester t, String at) async {
      final h = Harness(
        appearance: appearance,
        auth: FakeAuthRepository(
          restored: fakeUser(
            name: 'Nia Wairimu',
            appearance: dark ? MeDtoAppearance.dark : MeDtoAppearance.light,
          ),
        ),
        opportunities: repo(),
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

    testWidgets('opportunities home ${appearance.name}', (t) async {
      await open(t, '/opportunities');
      await shoot(t, 'opportunities_home');
    });

    testWidgets('opportunities list ${appearance.name}', (t) async {
      await open(t, '/opportunities/browse');
      await shoot(t, 'opportunities_list');
    });

    testWidgets('opportunity detail ${appearance.name}', (t) async {
      await open(t, '/opportunities/o-1');
      await shoot(t, 'opportunity_detail');
    });

    testWidgets('opportunity profile check ${appearance.name}', (t) async {
      await open(t, '/opportunities/o-1');
      await t.scrollUntilVisible(
        find.text('Your profile is missing 2 requirements'),
        300,
        scrollable: find
            .descendant(
              of: find.byType(RefreshIndicator).last,
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await t.drag(find.byType(RefreshIndicator).last, const Offset(0, -140));
      await t.pumpAndSettle();
      await shoot(t, 'opportunity_gap');
    });

    testWidgets('leaving atarah ${appearance.name}', (t) async {
      await open(t, '/opportunities/o-1');
      await t.tap(find.text('Apply on external website'));
      await t.pumpAndSettle();
      await shoot(t, 'opportunity_leave');
    });

    testWidgets('my opportunities ${appearance.name}', (t) async {
      await open(t, '/opportunities/mine');
      await shoot(t, 'opportunities_mine');
    });
  }
}
