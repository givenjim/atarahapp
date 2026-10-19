import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../support/app_harness.dart';
import '../support/fake_discover.dart';
import '../support/fakes.dart';

Future<Harness> openApp(
  WidgetTester t, {
  FakeDiscoverRepository? discover,
  String at = '/home',
}) async {
  final h = Harness(
    auth: FakeAuthRepository(restored: fakeUser(name: 'Nia Wairimu')),
    discover: discover,
  );
  await h.pump(t);
  // Tall, so a long list builds every row and the test can see all of it.
  t.view.physicalSize = const Size(390, 3000);
  h.router.go(at);
  await t.pumpAndSettle();
  return h;
}

const _debounce = Duration(milliseconds: 400);

void main() {
  group('Home', () {
    testWidgets(
      'shows only the greeting, the completion card and the shortcuts when there is nothing else',
      (t) async {
        await openApp(t, discover: FakeDiscoverRepository());
        expect(find.text('Welcome, Nia'), findsOneWidget);
        expect(find.text('60%'), findsOneWidget);
        expect(find.text('Quick Access'), findsOneWidget);
        // Sections without data are hidden, not drawn empty.
        expect(find.text('Recommended for you'), findsNothing);
        expect(find.text('Creatives to meet'), findsNothing);
        expect(find.text('Grow your creative career'), findsNothing);
        expect(find.text('Featured'), findsNothing);
        expect(find.text('Continue learning'), findsNothing);
        // The two labelled future tiles are always there.
        expect(find.text('Marketplace'), findsOneWidget);
        expect(find.text('Mentorship'), findsOneWidget);
      },
    );

    testWidgets('hides the completion card once the profile is complete', (
      t,
    ) async {
      await openApp(
        t,
        discover: FakeDiscoverRepository(home: homeDto(completion: 100)),
      );
      expect(find.text('Profile completion'), findsNothing);
      expect(find.text('Welcome, Nia'), findsOneWidget);
    });

    testWidgets(
      'explains every recommendation and every person, and opens them',
      (t) async {
        final repo = FakeDiscoverRepository(
          home: homeDto(
            article: articleCard(),
            recommended: const [
              RecommendationDto(
                type: RecommendationDtoType.article,
                id: 'a-1',
                title: 'Storyboarding for beginners',
                subtitle: 'Kiptoo Langat · 4 min read',
                path: '/articles/storyboarding',
                reason: 'Because you selected Animation and Visual Art',
              ),
            ],
            creatives: [
              creativeCard(
                handle: 'amani',
                name: 'Amani Otieno',
                reason: 'Also works in Animation',
              ),
            ],
          ),
          articleDetails: {
            'storyboarding': articleDto(
              slug: 'storyboarding',
              title: 'Storyboarding for beginners',
            ),
          },
        );
        final h = await openApp(t, discover: repo);
        expect(find.text('Recommended for you'), findsOneWidget);
        expect(
          find.text('Because you selected Animation and Visual Art'),
          findsOneWidget,
        );
        expect(find.text('Creatives to meet'), findsOneWidget);
        expect(find.text('Also works in Animation'), findsOneWidget);
        expect(find.text('Grow your creative career'), findsOneWidget);

        await tapText(t, 'Storyboarding for beginners');
        expect(h.path, '/articles/storyboarding');
        h.router.pop();
        await t.pumpAndSettle();

        await tapText(t, 'Amani Otieno');
        expect(h.path, '/creatives/amani');
      },
    );

    testWidgets('the bell says how many are unread and opens notifications', (
      t,
    ) async {
      final h = await openApp(
        t,
        discover: FakeDiscoverRepository(home: homeDto(unread: 3)),
      );
      expect(find.bySemanticsLabel('Notifications, 3 unread'), findsOneWidget);
      await t.tap(find.byIcon(LucideIcons.bell));
      await t.pumpAndSettle();
      expect(h.path, '/notifications');
    });

    testWidgets('Marketplace and Mentorship open labelled future screens', (
      t,
    ) async {
      final h = await openApp(t);
      await tapText(t, 'Marketplace');
      expect(h.path, '/soon/p2');
      expect(find.textContaining('Soon'), findsWidgets);
    });

    testWidgets('a failed load says so and retrying loads it', (t) async {
      final repo = FakeDiscoverRepository()
        ..homeFailure = const NetworkFailure();
      await openApp(t, discover: repo);
      expect(find.text("We couldn't load this"), findsOneWidget);
      repo.homeFailure = null;
      await tapText(t, 'Try again');
      expect(find.text('Welcome, Nia'), findsOneWidget);
    });

    testWidgets('the avatar opens the profile tab', (t) async {
      final h = await openApp(t);
      await t.tap(find.bySemanticsLabel('Your profile'));
      await t.pumpAndSettle();
      expect(h.path, '/profile');
    });
  });

  group('Explore', () {
    FakeDiscoverRepository people() {
      final repo = FakeDiscoverRepository(
        creatives: [
          creativeCard(handle: 'wanjiku', name: 'Wanjiku Njeri', open: true),
          creativeCard(
            handle: 'amani',
            name: 'Amani Otieno',
            discipline: 'Music',
            location: 'Mombasa',
            verified: true,
          ),
        ],
      );
      repo.disciplineOf['wanjiku'] = 'd-animation';
      repo.disciplineOf['amani'] = 'd-music';
      repo.countyOf['wanjiku'] = 'n-nbi';
      repo.countyOf['amani'] = 'n-msa';
      return repo;
    }

    testWidgets('lists creatives with their tick, role, skills and place', (
      t,
    ) async {
      await openApp(t, discover: people(), at: '/explore');
      expect(find.text('Explore creatives'), findsOneWidget);
      expect(find.text('2 creatives'), findsOneWidget);
      expect(find.text('Wanjiku Njeri'), findsOneWidget);
      expect(find.text('Illustrator and 2D animator'), findsWidgets);
      expect(find.text('Procreate'), findsWidgets);
      expect(find.text('Nairobi'), findsOneWidget);
      expect(find.byType(AtVerifiedTick), findsOneWidget);
      expect(find.text('Open to commissions'), findsOneWidget);
    });

    testWidgets(
      'a discipline narrows the list, and an empty one offers to show all',
      (t) async {
        final repo = people();
        repo.disciplineOf.remove('amani');
        await openApp(t, discover: repo, at: '/explore');
        await tapText(t, 'Music');
        expect(find.text('Amani Otieno'), findsNothing);
        expect(
          find.text('No creatives in this discipline yet nearby.'),
          findsOneWidget,
        );
        await tapText(t, 'Show all');
        expect(find.text('Amani Otieno'), findsOneWidget);
        expect(find.text('Wanjiku Njeri'), findsOneWidget);
      },
    );

    testWidgets('says plainly when nobody has finished a profile yet', (
      t,
    ) async {
      await openApp(t, discover: FakeDiscoverRepository(), at: '/explore');
      expect(find.text('No creatives to show yet'), findsOneWidget);
      expect(find.text('Show all'), findsNothing);
    });

    testWidgets('the filters sheet shows a live count and applies on Show', (
      t,
    ) async {
      final repo = people();
      await openApp(t, discover: repo, at: '/explore');
      await t.tap(find.bySemanticsLabel('Filters'));
      await t.pumpAndSettle();
      expect(find.text('Show 2 results'), findsOneWidget);

      await tapText(t, 'Verified only', last: true);
      expect(find.text('Show 1 result'), findsOneWidget);
      // Nothing changes behind the sheet until it is applied.
      expect(repo.creativeRequests.last.verified, isTrue);

      await tapText(t, 'Show 1 result');
      expect(find.text('Wanjiku Njeri'), findsNothing);
      expect(find.text('Amani Otieno'), findsOneWidget);
      // The filter shows as a chip that can be removed.
      await t.tap(find.byIcon(LucideIcons.x));
      await t.pumpAndSettle();
      expect(find.text('Wanjiku Njeri'), findsOneWidget);
    });

    testWidgets('Reset clears every group, and Open to commissions filters', (
      t,
    ) async {
      final repo = people();
      await openApp(t, discover: repo, at: '/explore');
      await t.tap(find.bySemanticsLabel('Filters'));
      await t.pumpAndSettle();
      await tapText(t, 'Open to commissions', last: true);
      expect(find.text('Show 1 result'), findsOneWidget);
      await tapText(t, 'Reset');
      expect(find.text('Show 2 results'), findsOneWidget);
    });

    testWidgets('a county can be chosen from the list', (t) async {
      final repo = people();
      await openApp(t, discover: repo, at: '/explore');
      await t.tap(find.bySemanticsLabel('Filters'));
      await t.pumpAndSettle();
      await tapText(t, 'Choose county');
      await tapText(t, 'Mombasa', last: true);
      expect(find.text('Show 1 result'), findsOneWidget);
      await tapText(t, 'Show 1 result');
      expect(find.text('Amani Otieno'), findsOneWidget);
      expect(find.text('Wanjiku Njeri'), findsNothing);
    });

    testWidgets(
      'every "More to explore" tile goes somewhere real or labelled',
      (t) async {
        final h = await openApp(t, discover: people(), at: '/explore');
        Future<void> check(String tile, String path) async {
          await t.ensureVisible(find.text(tile));
          await t.tap(find.text(tile));
          await t.pumpAndSettle();
          expect(h.path, path, reason: tile);
          h.router.pop();
          await t.pumpAndSettle();
        }

        await check('Marketplace', '/soon/p2');
        await check('Mentorship', '/soon/p2');
        await check('Creative economy', '/soon/p3');
        await check('Skill Labs', '/soon/p1');
        await check('Articles', '/articles');
      },
    );

    testWidgets('"Want to be discovered?" opens the Passport', (t) async {
      final h = await openApp(t, discover: people(), at: '/explore');
      await tapText(t, 'Want to be discovered?');
      expect(h.path, '/passport');
    });

    testWidgets('the search bar opens search', (t) async {
      final h = await openApp(t, discover: people(), at: '/explore');
      await t.tap(find.bySemanticsLabel('Search creatives, articles'));
      await t.pumpAndSettle();
      expect(h.path, '/search');
    });

    testWidgets('a failed load can be retried', (t) async {
      final repo = people()..creativesFailure = const NetworkFailure();
      await openApp(t, discover: repo, at: '/explore');
      expect(find.text("We couldn't load this"), findsOneWidget);
      repo.creativesFailure = null;
      await tapText(t, 'Try again');
      expect(find.text('Wanjiku Njeri'), findsOneWidget);
    });
  });

  group('Search', () {
    FakeDiscoverRepository index({List<String>? recents}) =>
        FakeDiscoverRepository(
          recents: recents,
          creativeHits: [
            creativeHit('wanjiku', 'Wanjiku Njeri'),
            creativeHit('wanjala', 'Wanjala Ouma', verified: true),
            creativeHit('wanjohi', 'Wanjohi Kamau'),
            creativeHit('wanjiru', 'Wanjiru Mwangi'),
          ],
          articleHits: [articleHit('wanjiku-story', 'The Wanjiku story')],
          articles: [articleCard(slug: 'wanjiku-story')],
          articleDetails: {
            'wanjiku-story': articleDto(
              slug: 'wanjiku-story',
              title: 'The Wanjiku story',
            ),
          },
        );

    Future<void> type(WidgetTester t, String text) async {
      await t.enterText(find.byType(TextField), text);
      await t.pump(_debounce);
      await t.pumpAndSettle();
    }

    testWidgets('groups results, shows counts and a few of each', (t) async {
      await openApp(t, discover: index(), at: '/search');
      await type(t, 'wanj');
      expect(find.text('All (5)'), findsOneWidget);
      expect(find.text('Creatives (4)'), findsOneWidget);
      expect(find.text('Articles (1)'), findsOneWidget);
      // Three of the four people, and a way to see them all.
      expect(find.text('Wanjiku Njeri'), findsOneWidget);
      expect(find.text('Wanjiru Mwangi'), findsNothing);
      expect(find.text('See all 4'), findsOneWidget);
      expect(find.byType(AtVerifiedTick), findsOneWidget);
    });

    testWidgets('See all opens one kind, and its tab does too', (t) async {
      final repo = index();
      await openApp(t, discover: repo, at: '/search');
      await type(t, 'wanj');
      await tapText(t, 'See all 4');
      expect(find.text('Wanjiru Mwangi'), findsOneWidget);
      expect(find.text('The Wanjiku story'), findsNothing);
      expect(repo.searches.last, startsWith('wanj|creatives'));
      await tapText(t, 'Articles (1)');
      expect(find.text('The Wanjiku story'), findsOneWidget);
      expect(find.text('Wanjiru Mwangi'), findsNothing);
    });

    testWidgets('waits for a pause in typing and needs two characters', (
      t,
    ) async {
      final repo = index();
      await openApp(t, discover: repo, at: '/search');
      await t.enterText(find.byType(TextField), 'w');
      await t.pump(_debounce);
      expect(repo.searches, isEmpty);
      expect(find.text('Type at least 2 characters.'), findsOneWidget);

      await t.enterText(find.byType(TextField), 'wa');
      await t.pump(const Duration(milliseconds: 100));
      await t.enterText(find.byType(TextField), 'wan');
      await t.pump(_debounce);
      await t.pumpAndSettle();
      // One request for the whole burst.
      expect(repo.searches, ['wan|all|1']);
    });

    testWidgets('opening a result remembers the search', (t) async {
      final repo = index();
      final h = await openApp(t, discover: repo, at: '/search');
      await type(t, 'wanj');
      await tapText(t, 'Wanjala Ouma');
      expect(h.path, '/creatives/wanjala');
      expect(repo.recorded, ['wanj']);
    });

    testWidgets('says so when nothing matches', (t) async {
      await openApp(t, discover: index(), at: '/search');
      await type(t, 'zzzz');
      expect(find.text('No results for "zzzz"'), findsOneWidget);
    });

    testWidgets('clearing the field brings the recent searches back', (
      t,
    ) async {
      await openApp(
        t,
        discover: index(recents: ['logo']),
        at: '/search',
      );
      await type(t, 'wanj');
      expect(find.text('Recent'), findsNothing);
      await t.tap(find.bySemanticsLabel('Clear search'));
      await t.pumpAndSettle();
      expect(find.text('Recent'), findsOneWidget);
      expect(find.text('logo'), findsOneWidget);
    });

    testWidgets('recent searches run again, delete one, and clear all', (
      t,
    ) async {
      final repo = index(recents: ['logo', 'wanj']);
      await openApp(t, discover: repo, at: '/search');
      expect(find.text('Recent'), findsOneWidget);

      await t.tap(find.bySemanticsLabel('Remove recent search logo'));
      await t.pumpAndSettle();
      expect(find.text('logo'), findsNothing);

      await tapText(t, 'wanj');
      expect(find.text('Creatives (4)'), findsOneWidget);
      await t.tap(find.bySemanticsLabel('Clear search'));
      await t.pumpAndSettle();
      await tapText(t, 'Clear all');
      expect(repo.recentList, isEmpty);
      expect(find.text('Search Atarah'), findsOneWidget);
    });

    testWidgets('a failed search can be retried', (t) async {
      final repo = index();
      await openApp(t, discover: repo, at: '/search');
      await type(t, 'wanj');
      expect(find.text('Wanjiku Njeri'), findsOneWidget);
    });
  });

  group('Article', () {
    testWidgets('shows source, byline, and every kind of block', (t) async {
      final repo = FakeDiscoverRepository(
        articleDetails: {'pricing-illustration': articleDto()},
      );
      await openApp(t, discover: repo, at: '/articles/pricing-illustration');
      expect(find.text('Atarah Editorial'), findsOneWidget);
      expect(
        find.text('How to price commissioned illustration in Kenya'),
        findsOneWidget,
      );
      expect(find.textContaining('Kiptoo Langat · 6 min read'), findsOneWidget);
      expect(find.text('Start with a day rate'), findsOneWidget);
      expect(
        find.text('Clients do not buy hours, they buy usage.'),
        findsOneWidget,
      );
      expect(find.text('Rule of thumb'), findsOneWidget);
      expect(
        find.text('An editorial spot is not a billboard.'),
        findsOneWidget,
      );
      expect(find.text('Price the usage.'), findsOneWidget);
      expect(find.text('Anonymous'), findsOneWidget);
    });

    testWidgets('a partner article names who it came from', (t) async {
      final repo = FakeDiscoverRepository(
        articleDetails: {
          'p': articleDto(
            slug: 'p',
            source: 'PARTNER',
            sourceLabel: 'Creative Economy Kenya',
          ),
        },
      );
      await openApp(t, discover: repo, at: '/articles/p');
      expect(find.text('Creative Economy Kenya'), findsOneWidget);
      expect(find.text('Atarah Editorial'), findsNothing);
    });

    testWidgets('saves and unsaves, putting the choice back if it fails', (
      t,
    ) async {
      final repo = FakeDiscoverRepository(
        articleDetails: {'pricing-illustration': articleDto()},
      );
      await openApp(t, discover: repo, at: '/articles/pricing-illustration');
      await t.tap(find.bySemanticsLabel('Save article'));
      await t.pumpAndSettle();
      expect(repo.saved, {'a-1'});
      expect(find.bySemanticsLabel('Remove from saved'), findsOneWidget);
      await t.tap(find.bySemanticsLabel('Remove from saved'));
      await t.pumpAndSettle();
      expect(repo.saved, isEmpty);
      expect(find.bySemanticsLabel('Save article'), findsOneWidget);
    });

    testWidgets('an article already saved shows as saved', (t) async {
      final repo = FakeDiscoverRepository(
        articleDetails: {'s': articleDto(slug: 's', saved: true)},
      );
      await openApp(t, discover: repo, at: '/articles/s');
      expect(find.bySemanticsLabel('Remove from saved'), findsOneWidget);
    });

    testWidgets('shares the title and the link', (t) async {
      final repo = FakeDiscoverRepository(
        articleDetails: {'pricing-illustration': articleDto()},
      );
      final h = await openApp(
        t,
        discover: repo,
        at: '/articles/pricing-illustration',
      );
      await t.tap(find.bySemanticsLabel('Share'));
      await t.pumpAndSettle();
      expect(h.shared.single, contains('How to price commissioned'));
      expect(h.shared.single, contains('https://atarah.app/articles/'));
    });

    testWidgets('one that is not available says so', (t) async {
      await openApp(t, at: '/articles/gone');
      expect(find.text('This article is not available'), findsOneWidget);
    });

    testWidgets('the articles list opens an article', (t) async {
      final repo = FakeDiscoverRepository(
        articles: [articleCard()],
        articleDetails: {'pricing-illustration': articleDto()},
      );
      final h = await openApp(t, discover: repo, at: '/articles');
      await tapText(t, 'How to price commissioned illustration in Kenya');
      expect(h.path, '/articles/pricing-illustration');
    });

    testWidgets('an empty articles list says so', (t) async {
      await openApp(t, at: '/articles');
      expect(find.text('No articles yet'), findsOneWidget);
    });
  });
}
