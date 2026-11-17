import 'dart:async';

import 'package:atarah/core/analytics/analytics.dart';
import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/l10n/app_localizations.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/core/providers.dart';
import 'package:atarah/features/community/groups/group_screen.dart';
import 'package:atarah/features/community/groups/groups_providers.dart';
import 'package:atarah/features/community/groups/groups_tab.dart';
import 'package:atarah/features/onboarding/onboarding_providers.dart';
import 'package:atarah/features/profile/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/fake_groups.dart';

/// The groups screens inside the real theme and localisations, with a small router around them.
class GroupsHarness {
  GroupsHarness(this.repo, {this.dark = false}) {
    container = ProviderContainer(
      retry: noAutomaticRetry,
      overrides: [
        groupsRepositoryProvider.overrideWithValue(repo),
        avatarImageProvider.overrideWithValue(
          (_) => MemoryImage(groupsTestPixel),
        ),
        shareTextProvider.overrideWithValue((text) async => shared.add(text)),
        analyticsProvider.overrideWithValue(RecordingAnalytics()),
      ],
    );
    router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: SafeArea(child: GroupsTab())),
        ),
        GoRoute(
          path: '/groups/:id',
          builder: (_, s) => GroupScreen(groupRef: s.pathParameters['id']!),
        ),
        GoRoute(
          path: '/compose',
          builder: (_, s) => Scaffold(
            body: Text('compose ${s.uri.queryParameters['groupId']}'),
          ),
        ),
        GoRoute(
          path: '/posts/:id',
          builder: (_, s) =>
              Scaffold(body: Text('post ${s.pathParameters['id']}')),
        ),
      ],
    );
  }

  final FakeGroupsRepository repo;
  final bool dark;
  final List<String> shared = [];
  late final ProviderContainer container;
  late final GoRouter router;

  Future<void> pump(WidgetTester t, {String at = '/'}) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    addTearDown(container.dispose);
    addTearDown(router.dispose);
    router.go(at);
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AtTheme.light,
          darkTheme: AtTheme.dark,
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await t.pumpAndSettle();
  }
}

FakeGroupsRepository _repo() => FakeGroupsRepository(
  mine: [
    groupCard(
      id: 'm-1',
      slug: 'kenya-illustrators',
      name: 'Kenya Illustrators',
      joined: true,
      members: 860,
    ),
  ],
  discover: [
    groupCard(),
    groupCard(
      id: 'g-2',
      slug: 'mombasa-makers',
      name: 'Mombasa Makers',
      type: GroupType.location,
      members: 1,
    ),
    groupCard(
      id: 'g-3',
      slug: 'owned',
      name: 'Owned By Me',
      type: GroupType.interest,
      joined: true,
      role: GroupCardDtoRole.owner,
    ),
  ],
);

void main() {
  group('Groups tab', () {
    testWidgets('shows your groups and the discover list', (t) async {
      await GroupsHarness(_repo()).pump(t);
      expect(find.text('Your groups'), findsOneWidget);
      expect(find.text('Kenya Illustrators'), findsOneWidget);
      expect(find.text('Discover groups'), findsOneWidget);
      expect(find.text('Nairobi Animators'), findsOneWidget);
      expect(find.text('Discipline · 1204 members'), findsOneWidget);
      expect(find.text('Location · 1 member'), findsOneWidget);
    });

    testWidgets('says so when you have no groups yet', (t) async {
      await GroupsHarness(FakeGroupsRepository(discover: [groupCard()]))
          .pump(t);
      expect(
        find.text("You haven't joined a group yet. Find one below."),
        findsOneWidget,
      );
    });

    testWidgets('a type chip narrows the list and search filters by name', (
      t,
    ) async {
      final repo = _repo();
      await GroupsHarness(repo).pump(t);
      await t.tap(find.widgetWithText(AtChip, 'Location'));
      await t.pumpAndSettle();
      expect(repo.typesAsked.last, GroupType.location);
      expect(find.text('Mombasa Makers'), findsOneWidget);
      expect(find.text('Nairobi Animators'), findsNothing);

      await t.tap(find.widgetWithText(AtChip, 'All'));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField), 'nairobi');
      await t.pump(const Duration(milliseconds: 450));
      await t.pumpAndSettle();
      expect(repo.searchesAsked.last, 'nairobi');
      expect(find.text('Nairobi Animators'), findsOneWidget);
      expect(find.text('Mombasa Makers'), findsNothing);
    });

    testWidgets('an empty result explains itself', (t) async {
      await GroupsHarness(FakeGroupsRepository()).pump(t);
      expect(find.text('No groups to show'), findsOneWidget);
    });

    testWidgets('a failed load can be retried', (t) async {
      final repo = FakeGroupsRepository(
        discover: [groupCard()],
        listFailure: const NetworkFailure(),
      );
      await GroupsHarness(repo).pump(t);
      expect(
        find.text("You're offline. Check your connection and try again."),
        findsOneWidget,
      );
      repo.listFailure = null;
      await t.tap(find.text('Try again'));
      await t.pumpAndSettle();
      expect(find.text('Nairobi Animators'), findsOneWidget);
    });

    testWidgets('joining is instant and keeps the server count', (t) async {
      final gate = Completer<void>();
      final repo = _repo()..gate = gate.future;
      await GroupsHarness(repo).pump(t);
      await t.tap(find.text('Join').first);
      await t.pump();
      // Optimistic: already Joined, with one more member, before the server answered.
      expect(find.text('Joined'), findsNWidgets(2));
      expect(find.text('Discipline · 1205 members'), findsOneWidget);
      gate.complete();
      await t.pumpAndSettle();
      expect(repo.calls, contains('join:g-1'));
      expect(find.text('You joined Nairobi Animators'), findsOneWidget);
    });

    testWidgets('a refused join rolls back and explains why', (t) async {
      final repo = _repo()
        ..joinFailure = const ApiFailure(
          code: 'VERIFICATION_REQUIRED',
          message: 'x',
          statusCode: 403,
          details: {'reason': 'CONTACT_NOT_VERIFIED'},
        );
      await GroupsHarness(repo).pump(t);
      await t.tap(find.text('Join').first);
      await t.pumpAndSettle();
      expect(find.text('Joined'), findsOneWidget); // the owned group only
      expect(find.text('Join'), findsNWidgets(2));
      expect(find.text('Discipline · 1204 members'), findsOneWidget);
      expect(
        find.text(
          'Verify your email or phone number to join groups and post in them.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('leaving asks first and can be cancelled', (t) async {
      final repo = FakeGroupsRepository(discover: [groupCard(joined: true)]);
      await GroupsHarness(repo).pump(t);
      await t.tap(find.text('Joined'));
      await t.pumpAndSettle();
      expect(find.text('Leave Nairobi Animators?'), findsOneWidget);
      await t.tap(find.text('Stay'));
      await t.pumpAndSettle();
      expect(repo.calls.where((c) => c.startsWith('leave')), isEmpty);
      expect(find.text('Joined'), findsOneWidget);

      await t.tap(find.text('Joined'));
      await t.pumpAndSettle();
      await t.tap(find.text('Leave group'));
      await t.pumpAndSettle();
      expect(repo.calls, contains('leave:g-1'));
      expect(find.text('Join'), findsOneWidget);
    });

    testWidgets('an owner cannot leave and is told kindly', (t) async {
      final repo = _repo();
      await GroupsHarness(repo).pump(t);
      await t.tap(find.text('Joined'));
      await t.pumpAndSettle();
      expect(find.textContaining("you can't leave it"), findsOneWidget);
      expect(find.text('Leave group'), findsNothing);
      expect(repo.calls.where((c) => c.startsWith('leave')), isEmpty);
    });

    testWidgets('the server refusing an owner leave shows the same words', (
      t,
    ) async {
      final repo = FakeGroupsRepository(
        discover: [groupCard(joined: true)],
        leaveFailure: const ApiFailure(
          code: 'INVALID_STATE',
          message: 'Owner cannot leave',
          statusCode: 409,
        ),
      );
      await GroupsHarness(repo).pump(t);
      await t.tap(find.text('Joined'));
      await t.pumpAndSettle();
      await t.tap(find.text('Leave group'));
      await t.pumpAndSettle();
      expect(find.textContaining("you can't leave it"), findsOneWidget);
      expect(find.text('Joined'), findsOneWidget);
    });

    testWidgets('opens a group', (t) async {
      final repo = _repo()..detailDto = groupDetailDto();
      final h = GroupsHarness(repo);
      await h.pump(t);
      await t.tap(find.text('Nairobi Animators'));
      await t.pumpAndSettle();
      expect(h.router.state.uri.path, '/groups/nairobi-animators');
      expect(find.text('Recent discussions'), findsOneWidget);
    });
  });

  group('Group screen', () {
    testWidgets('a member sees the pinned note, discussions and can post', (
      t,
    ) async {
      final repo = FakeGroupsRepository(
        detail: groupDetailDto(
          joined: true,
          canPost: true,
          official: true,
          pinned: groupPost(id: 'pin', body: 'Monthly crit night, 24 Oct'),
        ),
        postList: [
          groupPost(),
          groupPost(id: 'p-2', body: 'Who is going?'),
        ],
      );
      final h = GroupsHarness(repo);
      await h.pump(t, at: '/groups/g-1');
      expect(find.text('Nairobi Animators'), findsOneWidget);
      expect(find.text('Official'), findsOneWidget);
      expect(find.text('Joined'), findsOneWidget);
      expect(find.text('Monthly crit night, 24 Oct'), findsOneWidget);
      expect(find.text('Who is going?'), findsOneWidget);
      expect(find.text('31 replies'), findsWidgets);
      await t.tap(find.text('Start a discussion'));
      await t.pumpAndSettle();
      expect(
        h.router.state.uri.toString(),
        '/compose?groupId=g-1&groupName=Nairobi+Animators',
      );
    });

    testWidgets('a non-member is asked to join before posting', (t) async {
      final repo = FakeGroupsRepository(
        detail: groupDetailDto(),
        postList: [groupPost()],
      );
      await GroupsHarness(repo).pump(t, at: '/groups/nairobi-animators');
      expect(repo.calls, contains('detail:nairobi-animators'));
      expect(find.text('Join group'), findsOneWidget);
      expect(find.text('Join this group to post'), findsOneWidget);
      expect(find.text('Start a discussion'), findsNothing);
    });

    testWidgets('joining here unlocks posting', (t) async {
      final repo = FakeGroupsRepository(
        detail: groupDetailDto(),
        postList: [groupPost()],
      );
      await GroupsHarness(repo).pump(t, at: '/groups/g-1');
      await t.tap(find.text('Join group'));
      await t.pumpAndSettle();
      expect(find.text('Joined'), findsOneWidget);
      expect(find.text('Start a discussion'), findsOneWidget);
    });

    testWidgets('a private group is not joinable by a non-member', (t) async {
      final repo = FakeGroupsRepository(
        detail: groupDetailDto(visibility: GroupVisibility.private),
      );
      await GroupsHarness(repo).pump(t, at: '/groups/g-1');
      expect(find.text('Join group'), findsNothing);
      expect(
        find.text('Private group. Members are added by invitation.'),
        findsOneWidget,
      );
    });

    testWidgets('a group that is missing, private to you or archived', (
      t,
    ) async {
      final repo = FakeGroupsRepository(
        detailFailure: const ApiFailure(
          code: 'RESOURCE_NOT_FOUND',
          message: 'Not found',
          statusCode: 404,
        ),
      );
      await GroupsHarness(repo).pump(t, at: '/groups/nope');
      expect(find.text("This group isn't available"), findsOneWidget);
    });

    testWidgets('offline shows a retry that works', (t) async {
      final repo = FakeGroupsRepository(detailFailure: const NetworkFailure());
      await GroupsHarness(repo).pump(t, at: '/groups/g-1');
      expect(find.text("We couldn't load this"), findsOneWidget);
      repo.detailFailure = null;
      repo.detailDto = groupDetailDto();
      await t.tap(find.text('Try again'));
      await t.pumpAndSettle();
      expect(find.text('Nairobi Animators'), findsOneWidget);
    });

    testWidgets('discussions load page by page', (t) async {
      final repo = FakeGroupsRepository(
        detail: groupDetailDto(joined: true, canPost: true),
        postPages: [
          [groupPost(id: 'a', body: 'First page post')],
          [groupPost(id: 'b', body: 'Second page post')],
        ],
      );
      await GroupsHarness(repo).pump(t, at: '/groups/g-1');
      expect(find.text('First page post'), findsOneWidget);
      await t.ensureVisible(find.text('Show more discussions'));
      await t.tap(find.text('Show more discussions'));
      await t.pumpAndSettle();
      expect(repo.calls, contains('posts:g-1:c1'));
      expect(find.text('Second page post'), findsOneWidget);
      expect(find.text('Show more discussions'), findsNothing);
    });

    testWidgets('a group with no discussions says so', (t) async {
      final repo = FakeGroupsRepository(
        detail: groupDetailDto(joined: true, canPost: true),
      );
      await GroupsHarness(repo).pump(t, at: '/groups/g-1');
      expect(find.text('No discussions yet'), findsOneWidget);
    });

    testWidgets('discussions failing leaves the rest of the group usable', (
      t,
    ) async {
      final repo = FakeGroupsRepository(
        detail: groupDetailDto(joined: true, canPost: true),
        postsFailure: const NetworkFailure(),
      );
      await GroupsHarness(repo).pump(t, at: '/groups/g-1');
      expect(find.text("We couldn't load the discussions"), findsOneWidget);
      expect(find.text('Nairobi Animators'), findsOneWidget);
    });

    testWidgets('shares the group link', (t) async {
      final repo = FakeGroupsRepository(detail: groupDetailDto());
      final h = GroupsHarness(repo);
      await h.pump(t, at: '/groups/g-1');
      await t.tap(find.bySemanticsLabel('Share group'));
      await t.pumpAndSettle();
      expect(
        h.shared.single,
        contains('https://atarah.app/groups/nairobi-animators'),
      );
    });

    testWidgets('a discussion opens its post', (t) async {
      final repo = FakeGroupsRepository(
        detail: groupDetailDto(),
        postList: [groupPost(id: 'p-9')],
      );
      final h = GroupsHarness(repo);
      await h.pump(t, at: '/groups/g-1');
      await t.tap(find.textContaining('lip-sync'));
      await t.pumpAndSettle();
      expect(h.router.state.uri.path, '/posts/p-9');
    });
  });
}
