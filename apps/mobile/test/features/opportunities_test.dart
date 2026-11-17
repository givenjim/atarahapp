import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../support/app_harness.dart';
import '../support/fake_opportunities.dart';
import '../support/fakes.dart';

Future<Harness> openApp(
  WidgetTester t, {
  FakeOpportunitiesRepository? repo,
  String at = '/opportunities',
}) async {
  final h = Harness(
    auth: FakeAuthRepository(restored: fakeUser(name: 'Nia Wairimu')),
    opportunities:
        repo ?? FakeOpportunitiesRepository(opportunities: [oppDto()]),
  );
  await h.pump(t);
  h.router.go(at);
  await t.pumpAndSettle();
  return h;
}

/// Scrolls the detail or list page (the one with the pull-to-refresh) until [finder] is on screen.
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

/// The background of the pill that holds [text] (the deadline tile on a card).
Color? tileColor(WidgetTester t, String text) {
  final box = find.ancestor(
    of: find.text(text),
    matching: find.byType(Container),
  );
  for (final c in t.widgetList<Container>(box)) {
    final d = c.decoration;
    if (d is BoxDecoration && d.color != null) return d.color;
  }
  return null;
}

final _missingGap = gapOf([
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
]);

void main() {
  group('Opportunities home', () {
    testWidgets('shows the saved count, categories and the three sections', (
      t,
    ) async {
      final repo = FakeOpportunitiesRepository(
        opportunities: [
          oppDto(id: 'f', title: 'Digital Storytelling Grant', featured: true),
          oppDto(
            id: 'c',
            title: 'Animation Futures Fund',
            daysLeft: 3,
            urgency: OpportunityDtoUrgency.urgent,
          ),
          oppDto(
            id: 'r',
            title: 'Explainer video for a launch',
            type: OpportunityType.gig,
            trust: OpportunityTrust.externalSource,
            daysLeft: 40,
          ),
        ],
        trackings: {'r': trackingOf(OpportunityTrackingStatus.saved)},
      );
      await openApp(t, repo: repo);
      expect(find.text('Opportunities'), findsWidgets);
      expect(find.text('Search grants, gigs, jobs…'), findsOneWidget);
      for (final c in ['All', 'Funding', 'Grants', 'Jobs']) {
        expect(find.text(c), findsOneWidget, reason: c);
      }
      expect(
        find.byWidgetPredicate((w) => w is AtIconButton && w.badge == 1),
        findsOneWidget,
      );
      expect(find.text('Featured'), findsOneWidget);
      await reveal(t, find.text('Closing soon'));
      await reveal(t, find.text('Recently added'));
      expect(find.text('Animation Futures Fund'), findsWidgets);
    });

    testWidgets('a category tile opens its list; the bookmark opens saved', (
      t,
    ) async {
      final repo = FakeOpportunitiesRepository(
        opportunities: [
          oppDto(),
          oppDto(id: 'g', title: 'Weekend gig', type: OpportunityType.gig),
        ],
      );
      final h = await openApp(t, repo: repo);
      await tapText(t, 'Grants');
      expect(h.path, '/opportunities/browse');
      expect(repo.calls, contains('list:GRANT:deadline:1'));
      expect(find.text('Weekend gig'), findsNothing);
      h.router.go('/opportunities');
      await t.pumpAndSettle();
      await t.tap(find.widgetWithIcon(AtIconButton, LucideIcons.bookmark));
      await t.pumpAndSettle();
      expect(h.path, '/opportunities/mine');
      expect(find.text('Saved opportunities'), findsOneWidget);
      expect(find.text('Nothing saved yet'), findsOneWidget);
    });

    testWidgets('empty and error states', (t) async {
      await openApp(t, repo: FakeOpportunitiesRepository());
      expect(find.text('Nothing open right now'), findsOneWidget);
    });

    testWidgets('a failure says so and retry works', (t) async {
      final repo = FakeOpportunitiesRepository(opportunities: [oppDto()])
        ..homeFailure = const NetworkFailure();
      await openApp(t, repo: repo);
      expect(find.textContaining("You're offline"), findsOneWidget);
      repo.homeFailure = null;
      await t.tap(find.text('Try again'));
      await t.pumpAndSettle();
      expect(find.text('Emerging Creatives Grant 2027'), findsWidgets);
    });
  });

  group('Cards', () {
    testWidgets(
      '7 days or fewer is coral, 8 to 14 is tangerine, later is plain',
      (t) async {
        final repo = FakeOpportunitiesRepository(
          opportunities: [
            oppDto(
              id: 'a',
              title: 'Seven',
              daysLeft: 7,
              urgency: OpportunityDtoUrgency.urgent,
            ),
            oppDto(
              id: 'b',
              title: 'Fourteen',
              daysLeft: 14,
              urgency: OpportunityDtoUrgency.soon,
            ),
            oppDto(id: 'c', title: 'Later', daysLeft: 60),
          ],
        );
        await openApp(t, repo: repo, at: '/opportunities/browse');
        const colors = AtColors.light;
        expect(tileColor(t, '7 days left'), colors.coralSurface);
        expect(tileColor(t, '14 days left'), colors.tangerineSurface);
        expect(
          tileColor(t, '7 days left'),
          isNot(tileColor(t, '14 days left')),
        );
        expect(find.text('7 days left'), findsOneWidget);
        // A deadline beyond two weeks shows the date, not a countdown.
        expect(find.textContaining('days left'), findsNWidgets(2));
      },
    );

    testWidgets('the trust badge says exactly what Atarah knows', (t) async {
      final repo = FakeOpportunitiesRepository(
        opportunities: [
          oppDto(
            id: 'a',
            title: 'Verified one',
            trust: OpportunityTrust.verified,
          ),
          oppDto(
            id: 'b',
            title: 'Confirmed one',
            trust: OpportunityTrust.sourceConfirmed,
          ),
          oppDto(
            id: 'c',
            title: 'Unknown one',
            trust: OpportunityTrust.externalSource,
          ),
        ],
      );
      await openApp(t, repo: repo, at: '/opportunities/browse');
      expect(find.text('Verified by Atarah'), findsOneWidget);
      expect(find.text('Source confirmed'), findsOneWidget);
      expect(find.text('External source'), findsOneWidget);
      expect(find.byIcon(LucideIcons.badgeCheck), findsOneWidget);
    });

    testWidgets('saving flips at once; a refusal flips back and says why', (
      t,
    ) async {
      final repo = FakeOpportunitiesRepository(opportunities: [oppDto()]);
      await openApp(t, repo: repo, at: '/opportunities/browse');
      await t.tap(find.bySemanticsLabel('Save Emerging Creatives Grant 2027'));
      await t.pumpAndSettle();
      expect(repo.calls, contains('save:o-1'));
      expect(
        find.bySemanticsLabel(
          'Remove from saved: Emerging Creatives Grant 2027',
        ),
        findsOneWidget,
      );

      // Started applying: the server refuses to un-save, and the bookmark returns.
      repo.trackings['o-1'] = trackingOf(OpportunityTrackingStatus.inProgress);
      await t.tap(
        find.bySemanticsLabel(
          'Remove from saved: Emerging Creatives Grant 2027',
        ),
      );
      await t.pump();
      await t.pumpAndSettle();
      expect(
        find.text(
          'You have started this one. Mark it applied or completed instead.',
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          'Remove from saved: Emerging Creatives Grant 2027',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a failed save rolls the bookmark back', (t) async {
      final repo = FakeOpportunitiesRepository(opportunities: [oppDto()])
        ..saveFailure = const NetworkFailure();
      await openApp(t, repo: repo, at: '/opportunities/browse');
      await t.tap(find.bySemanticsLabel('Save Emerging Creatives Grant 2027'));
      await t.pumpAndSettle();
      expect(
        find.bySemanticsLabel('Save Emerging Creatives Grant 2027'),
        findsOneWidget,
      );
      expect(find.textContaining("You're offline"), findsOneWidget);
    });
  });

  group('List', () {
    testWidgets('title, open count, sort and filters', (t) async {
      final repo = FakeOpportunitiesRepository(
        opportunities: [
          oppDto(id: 'a', title: 'One'),
          oppDto(id: 'b', title: 'Two', trust: OpportunityTrust.externalSource),
        ],
      );
      final h = await openApp(t, repo: repo);
      h.router.go('/opportunities/browse?type=GRANT');
      await t.pumpAndSettle();
      expect(find.text('Grants'), findsWidgets);
      expect(find.text('2 open grants'), findsOneWidget);
      expect(find.text('Deadline: soonest'), findsOneWidget);

      await tapText(t, 'Deadline: soonest');
      await tapText(t, 'Recently added');
      expect(repo.calls.last, 'list:GRANT:recent:1');

      await t.tap(find.bySemanticsLabel('Filters'));
      await t.pumpAndSettle();
      await tapText(t, 'External source', last: true);
      await tapText(t, 'Apply filters');
      expect(repo.listFilters.last.trust, OpportunityTrust.externalSource);
      expect(repo.listFilters.last.sort.json, 'recent');
      expect(find.text('Two'), findsOneWidget);
      expect(find.text('One'), findsNothing);
      expect(find.text('1 open grants'), findsOneWidget);
    });

    testWidgets('no match says how to widen it', (t) async {
      final repo = FakeOpportunitiesRepository(opportunities: [oppDto()]);
      final h = await openApp(t, repo: repo);
      h.router.go('/opportunities/browse?type=JOB');
      await t.pumpAndSettle();
      expect(find.text('Nothing open right now'), findsOneWidget);
    });

    testWidgets('pages in more when the member scrolls', (t) async {
      final repo = FakeOpportunitiesRepository(
        pageSize: 5,
        opportunities: [
          for (var i = 0; i < 12; i++) oppDto(id: 'o-$i', title: 'Listing $i'),
        ],
      );
      await openApp(t, repo: repo, at: '/opportunities/browse');
      expect(repo.calls.where((c) => c.startsWith('list')), [
        'list:all:deadline:1',
      ]);
      await t.drag(find.byType(Scrollable).first, const Offset(0, -3000));
      await t.pumpAndSettle();
      expect(repo.calls, contains('list:all:deadline:2'));
    });
  });

  group('Detail', () {
    testWidgets('shows the facts, sections, provider tick and trust badge', (
      t,
    ) async {
      final h = await openApp(t, at: '/opportunities/o-1');
      expect(h.path, '/opportunities/o-1');
      expect(find.text('Emerging Creatives Grant 2027'), findsOneWidget);
      expect(find.text('Verified by Atarah'), findsWidgets);
      expect(find.text('Nairobi Creative Fund'), findsOneWidget);
      expect(find.text('KES 150,000 to 400,000'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      await reveal(t, find.text('Benefits'));
      expect(find.text('Requirements'), findsOneWidget);
      expect(find.text('Unrestricted grant'), findsOneWidget);
      expect(find.text('Apply on external website'), findsOneWidget);
    });

    testWidgets('an unverified listing never claims Atarah verified it', (
      t,
    ) async {
      await openApp(
        t,
        repo: FakeOpportunitiesRepository(
          opportunities: [oppDto(trust: OpportunityTrust.externalSource)],
        ),
        at: '/opportunities/o-1',
      );
      expect(find.text('Verified by Atarah'), findsNothing);
      expect(find.text('External source'), findsWidgets);
    });

    testWidgets('the profile check lists met, missing and unknown rows', (
      t,
    ) async {
      final repo = FakeOpportunitiesRepository(
        opportunities: [oppDto(gap: _missingGap)],
      );
      await openApp(t, repo: repo, at: '/opportunities/o-1');
      await reveal(t, find.text('Your profile is missing 2 requirements'));
      expect(find.text('Add them before you apply'), findsOneWidget);
      expect(find.text('1/4'), findsOneWidget);
      expect(find.text('At least 3 published projects'), findsOneWidget);
      expect(find.text('You have 1 of 3 published projects.'), findsOneWidget);
      expect(find.text('Based in Kenya'), findsOneWidget);
      expect(
        find.text('Artist statement needed. Documents arrive soon.'),
        findsOneWidget,
      );
      expect(find.text('Add'), findsNWidgets(2));
      expect(find.text('Soon'), findsOneWidget);
    });

    testWidgets('Add opens the fix screen and the check is asked again after', (
      t,
    ) async {
      final repo = FakeOpportunitiesRepository(
        opportunities: [oppDto(gap: _missingGap)],
      );
      final h = await openApp(t, repo: repo, at: '/opportunities/o-1');
      await reveal(t, find.text('At least 3 published projects'));
      await t.tap(find.text('Add').first);
      await t.pumpAndSettle();
      expect(h.path, '/portfolio/new/edit');
      expect(repo.calls.where((c) => c.endsWith('refresh')), isEmpty);
      h.router.pop();
      await t.pumpAndSettle();
      expect(repo.calls, contains('detail:o-1:refresh'));
    });

    testWidgets('pull to refresh asks the server to skip its cache', (t) async {
      final repo = FakeOpportunitiesRepository(opportunities: [oppDto()]);
      await openApp(t, repo: repo, at: '/opportunities/o-1');
      await t.drag(find.byType(ListView).first, const Offset(0, 400));
      await t.pumpAndSettle();
      expect(repo.calls, contains('detail:o-1:refresh'));
    });

    testWidgets('ready, unchecked and no-rules each say their own thing', (
      t,
    ) async {
      Future<void> check(ProfileGapDto gap, String headline) async {
        await openApp(
          t,
          repo: FakeOpportunitiesRepository(opportunities: [oppDto(gap: gap)]),
          at: '/opportunities/o-1',
        );
        await reveal(t, find.text(headline));
        expect(find.text(headline), findsOneWidget);
      }

      await check(
        gapOf([rule(state: RuleResultDtoState.met, detail: null, fix: null)]),
        'You meet the requirements Atarah can check',
      );
    });

    testWidgets('unchecked rules are not counted as missing', (t) async {
      await openApp(
        t,
        repo: FakeOpportunitiesRepository(
          opportunities: [
            oppDto(
              gap: gapOf([
                rule(
                  state: RuleResultDtoState.unknown,
                  label: 'Aged 18 to 35',
                  detail:
                      'Atarah cannot check this. The provider will confirm it.',
                  fix: null,
                ),
              ]),
            ),
          ],
        ),
        at: '/opportunities/o-1',
      );
      await reveal(t, find.text("Atarah can't check these requirements"));
      expect(find.textContaining('missing'), findsNothing);
      expect(
        find.text('Atarah cannot check this. The provider will confirm it.'),
        findsOneWidget,
      );
    });

    testWidgets('no requirements listed', (t) async {
      await openApp(t, at: '/opportunities/o-1');
      await reveal(t, find.text('No special requirements listed'));
      expect(find.text('0/0'), findsNothing);
    });

    testWidgets('Help me understand this is Soon · P3', (t) async {
      final h = await openApp(t, at: '/opportunities/o-1');
      await reveal(t, find.text('Help me understand this'));
      await t.tap(find.text('Help me understand this'));
      await t.pumpAndSettle();
      expect(h.path, '/soon/p3');
      expect(find.text('Soon · P3'), findsOneWidget);
    });

    testWidgets(
      'an email listing says so and a closed one has no way to apply',
      (t) async {
        await openApp(
          t,
          repo: FakeOpportunitiesRepository(
            opportunities: [
              oppDto(
                id: 'e',
                method: ApplicationMethod.email,
                url: null,
                email: 'jobs@studio.co.ke',
                domain: 'studio.co.ke',
              ),
              oppDto(id: 'x', closed: true, title: 'Gone by now'),
            ],
          ),
          at: '/opportunities/e',
        );
        expect(find.text('Apply by email'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        final h = Harness(
          auth: FakeAuthRepository(restored: fakeUser()),
          opportunities: FakeOpportunitiesRepository(
            opportunities: [
              oppDto(id: 'x', closed: true, title: 'Gone by now'),
            ],
          ),
        );
        await t.pumpWidget(const SizedBox());
        await h.pump(t);
        h.router.go('/opportunities/x');
        await t.pumpAndSettle();
        expect(find.text('Closed'), findsWidgets);
        expect(
          find.textContaining('This opportunity has closed'),
          findsOneWidget,
        );
        expect(find.text('Apply on external website'), findsNothing);
      },
    );

    testWidgets('a missing listing is not a crash', (t) async {
      await openApp(t, at: '/opportunities/nope');
      expect(
        find.text('That opportunity is not available any more.'),
        findsOneWidget,
      );
    });

    testWidgets('un-saving a started application shows the server words', (
      t,
    ) async {
      final repo = FakeOpportunitiesRepository(
        opportunities: [oppDto()],
        trackings: {'o-1': trackingOf(OpportunityTrackingStatus.inProgress)},
      );
      await openApp(t, repo: repo, at: '/opportunities/o-1');
      await t.tap(
        find.bySemanticsLabel(
          'Remove from saved: Emerging Creatives Grant 2027',
        ),
      );
      await t.pumpAndSettle();
      expect(
        find.text(
          'You have started this one. Mark it applied or completed instead.',
        ),
        findsOneWidget,
      );
    });
  });

  group('Leaving Atarah', () {
    Future<Harness> leave(
      WidgetTester t,
      FakeOpportunitiesRepository repo,
    ) async {
      final h = await openApp(t, repo: repo, at: '/opportunities/o-1');
      await t.tap(find.text('Apply on external website'));
      await t.pumpAndSettle();
      return h;
    }

    testWidgets('names the domain and says Atarah does not process it', (
      t,
    ) async {
      await leave(t, FakeOpportunitiesRepository(opportunities: [oppDto()]));
      expect(find.text("You're leaving Atarah"), findsOneWidget);
      expect(
        find.text(
          "You're going to funds.example.org. Atarah doesn't receive or process this application.",
        ),
        findsOneWidget,
      );
      expect(find.text('Track this as applied in Activity'), findsOneWidget);
    });

    testWidgets(
      'continue with the box ticked opens the site then records APPLIED',
      (t) async {
        final repo = FakeOpportunitiesRepository(opportunities: [oppDto()]);
        final h = await leave(t, repo);
        await t.tap(find.text('Continue to website'));
        await t.pumpAndSettle();
        expect(h.opened.map((u) => u.toString()), [
          'https://funds.example.org/apply',
        ]);
        expect(repo.calls, contains('track:o-1:APPLIED'));
        // The detail now shows the member's step: it can be completed.
        await reveal(t, find.text('Mark as completed'));
        expect(find.text('Mark as completed'), findsOneWidget);
      },
    );

    testWidgets(
      'continue with the box cleared opens the site and records nothing',
      (t) async {
        final repo = FakeOpportunitiesRepository(opportunities: [oppDto()]);
        final h = await leave(t, repo);
        await t.tap(find.text('Track this as applied in Activity'));
        await t.pump();
        await t.tap(find.text('Continue to website'));
        await t.pumpAndSettle();
        expect(h.opened, hasLength(1));
        expect(repo.calls.where((c) => c.startsWith('track')), isEmpty);
      },
    );

    testWidgets('Stay on Atarah opens nothing and records nothing', (t) async {
      final repo = FakeOpportunitiesRepository(opportunities: [oppDto()]);
      final h = await leave(t, repo);
      await t.tap(find.text('Stay on Atarah'));
      await t.pumpAndSettle();
      expect(h.opened, isEmpty);
      expect(repo.calls.where((c) => c.startsWith('track')), isEmpty);
      expect(find.text("You're leaving Atarah"), findsNothing);
    });

    testWidgets('an email listing opens a mailto link', (t) async {
      final repo = FakeOpportunitiesRepository(
        opportunities: [
          oppDto(
            method: ApplicationMethod.email,
            url: null,
            email: 'jobs@studio.co.ke',
            domain: 'studio.co.ke',
          ),
        ],
      );
      final h = await openApp(t, repo: repo, at: '/opportunities/o-1');
      await t.tap(find.text('Apply by email'));
      await t.pumpAndSettle();
      await t.tap(find.text('Continue to website'));
      await t.pumpAndSettle();
      expect(h.opened.single.toString(), 'mailto:jobs@studio.co.ke');
    });
  });

  group('My opportunities', () {
    FakeOpportunitiesRepository withItems() => FakeOpportunitiesRepository(
      opportunities: [
        oppDto(id: 'a', title: 'Applied gig', type: OpportunityType.gig),
        oppDto(id: 's', title: 'Saved grant', daysLeft: 30),
        oppDto(
          id: 'c',
          title: 'Closing grant',
          daysLeft: 4,
          urgency: OpportunityDtoUrgency.urgent,
        ),
        oppDto(id: 'd', title: 'Done job', type: OpportunityType.job),
      ],
      trackings: {
        's': trackingOf(OpportunityTrackingStatus.saved),
        'c': trackingOf(OpportunityTrackingStatus.saved),
        'a': trackingOf(OpportunityTrackingStatus.applied),
        'd': trackingOf(
          OpportunityTrackingStatus.completed,
          outcome: OpportunityOutcome.notSelected,
        ),
      },
    );

    testWidgets(
      'tabs filter, each item says where the member is, counts show',
      (t) async {
        final repo = withItems();
        await openApp(t, repo: repo, at: '/opportunities/mine');
        expect(find.text('My opportunities'), findsOneWidget);
        expect(find.text('Saved grant'), findsOneWidget);
        expect(find.text('Applied gig'), findsOneWidget);
        expect(find.text('2 saved · 1 applied · 1 completed'), findsOneWidget);
        expect(find.textContaining('Applied externally'), findsOneWidget);
        expect(find.text('Closing in 4 days'), findsOneWidget);

        await tapText(t, 'Closing soon');
        expect(find.text('Closing grant'), findsOneWidget);
        expect(find.text('Saved grant'), findsNothing);
        await tapText(t, 'Applied');
        expect(find.text('Applied gig'), findsOneWidget);
        expect(find.text('Closing grant'), findsNothing);
        await tapText(t, 'Completed');
        expect(find.text('Done job'), findsOneWidget);
        expect(find.text('Completed · Not selected'), findsOneWidget);
      },
    );

    testWidgets('empty states use their own words', (t) async {
      await openApp(
        t,
        repo: FakeOpportunitiesRepository(),
        at: '/opportunities/mine',
      );
      expect(find.text('Nothing tracked yet'), findsOneWidget);
      await tapText(t, 'Closing soon');
      expect(find.text('Nothing closing soon'), findsOneWidget);
      await tapText(t, 'Applied');
      expect(find.text('No applications yet'), findsOneWidget);
      await tapText(t, 'Completed');
      expect(find.text('Nothing completed yet'), findsOneWidget);
      expect(
        find.text(
          'Opportunities you finish will be kept here for your Creative Passport.',
        ),
        findsOneWidget,
      );
      expect(find.text('Explore opportunities'), findsOneWidget);
    });

    testWidgets('completing with an outcome records it', (t) async {
      final repo = withItems();
      await openApp(t, repo: repo, at: '/opportunities/mine');
      await tapText(t, 'Mark as completed');
      expect(find.text('How did it go?'), findsOneWidget);
      // Nothing is chosen yet, so nothing can be saved.
      await tapText(t, 'Withdrawn');
      await tapText(t, 'Save outcome');
      expect(repo.calls, contains('track:a:COMPLETED:WITHDRAWN'));
      await tapText(t, 'Completed');
      expect(find.text('Completed · Withdrawn'), findsOneWidget);
    });

    testWidgets('a win offers to add an achievement', (t) async {
      final repo = withItems();
      final h = await openApp(t, repo: repo, at: '/opportunities/mine');
      await tapText(t, 'Mark as completed');
      await tapText(t, 'Awarded');
      await tapText(t, 'Save outcome');
      expect(find.text('Congratulations!'), findsOneWidget);
      await tapText(t, 'Add this to your achievements');
      expect(h.path, '/achievements');
    });

    testWidgets('not now keeps the member where they are', (t) async {
      final repo = withItems();
      final h = await openApp(t, repo: repo, at: '/opportunities/mine');
      await tapText(t, 'Mark as completed');
      await tapText(t, 'Awarded');
      await tapText(t, 'Save outcome');
      await tapText(t, 'Not now');
      expect(h.path, '/opportunities/mine');
    });

    testWidgets('a refused step says why and changes nothing', (t) async {
      final repo = withItems()
        ..trackFailure = const ApiFailure(
          code: 'INVALID_STATE',
          message: 'This application is already completed.',
          statusCode: 409,
        );
      await openApp(t, repo: repo, at: '/opportunities/mine');
      await tapText(t, 'Mark as completed');
      await tapText(t, 'Awarded');
      await tapText(t, 'Save outcome');
      expect(
        find.text('This application is already completed.'),
        findsOneWidget,
      );
      expect(find.text('Congratulations!'), findsNothing);
    });
  });

  group('Links into the app', () {
    testWidgets('a notification link opens the opportunity', (t) async {
      final h = await openApp(t, at: '/opportunities/o-1');
      expect(h.path, '/opportunities/o-1');
      expect(find.text('Emerging Creatives Grant 2027'), findsOneWidget);
    });

    testWidgets('browse is not read as an id', (t) async {
      final repo = FakeOpportunitiesRepository(opportunities: [oppDto()]);
      await openApp(t, repo: repo, at: '/opportunities/browse');
      expect(repo.calls.any((c) => c.startsWith('detail')), isFalse);
      expect(repo.calls.any((c) => c.startsWith('list')), isTrue);
    });

    testWidgets('mine is not read as an id', (t) async {
      final repo = FakeOpportunitiesRepository(opportunities: [oppDto()]);
      await openApp(t, repo: repo, at: '/opportunities/mine');
      expect(repo.calls.any((c) => c.startsWith('detail')), isFalse);
      expect(repo.calls.any((c) => c.startsWith('mine')), isTrue);
    });
  });
}
