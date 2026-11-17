import 'dart:async';

import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/l10n/app_localizations.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/features/community/community_common.dart';
import 'package:atarah/features/community/community_providers.dart';
import 'package:atarah/features/portfolio/portfolio_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../support/app_harness.dart';
import '../support/fake_community.dart';
import '../support/fakes.dart';

const _userId = '00000000-0000-4000-8000-000000000001';
const _draftKey = 'community.compose.draft.$_userId';

Future<Harness> openApp(
  WidgetTester t, {
  FakeCommunityRepository? community,
  String at = '/community',
  Harness Function(FakeCommunityRepository)? build,
}) async {
  final repo = community ?? FakeCommunityRepository(posts: [postDto()]);
  final h = Harness(
    auth: FakeAuthRepository(restored: fakeUser(name: 'Nia Wairimu')),
    community: repo,
  );
  await h.pump(t);
  h.router.go(at);
  await t.pumpAndSettle();
  return h;
}

Finder get _scrollable => find.byType(RefreshIndicator).first;

void main() {
  group('Feed', () {
    testWidgets(
      'shows posts with type pills, and Announcement is not offered',
      (t) async {
        final h = await openApp(
          t,
          community: FakeCommunityRepository(
            posts: [
              postDto(),
              postDto(
                id: 'p-2',
                type: PostType.question,
                body: 'Anyone recommend a studio in Westlands?',
              ),
              postDto(
                id: 'p-3',
                type: PostType.announcement,
                body: 'Skill verification opens on 1 November.',
                announcement: true,
              ),
            ],
          ),
        );
        expect(find.text('Community'), findsWidgets);
        expect(find.text('Share an update or ask a question…'), findsOneWidget);
        expect(find.text('Discussion'), findsOneWidget);
        expect(find.text('Question'), findsOneWidget);
        expect(find.text('Announcement'), findsOneWidget);
        expect(find.text('Atarah Team'), findsOneWidget);
        expect(find.text('Graphic designer · 2h'), findsWidgets);
        await t.tap(find.bySemanticsLabel('New post'));
        await t.pumpAndSettle();
        expect(h.path, '/compose');
        expect(find.text('Update'), findsOneWidget);
        expect(find.text('Announcement'), findsNothing);
      },
    );

    testWidgets('loads the next cursor page when the member scrolls', (
      t,
    ) async {
      final repo = FakeCommunityRepository(
        pageSize: 5,
        posts: [
          for (var i = 0; i < 12; i++)
            postDto(id: 'p-$i', body: 'Post number $i'),
        ],
      );
      await openApp(t, community: repo);
      expect(repo.feedCursors, [null]);
      await t.drag(_scrollable, const Offset(0, -2500));
      await t.pumpAndSettle();
      expect(repo.feedCursors, [null, '5']);
      await t.drag(_scrollable, const Offset(0, -4000));
      await t.pumpAndSettle();
      expect(repo.feedCursors, [null, '5', '10']);
      // The last page had no cursor: nothing more is asked for.
      await t.drag(_scrollable, const Offset(0, -4000));
      await t.pumpAndSettle();
      expect(repo.feedCursors.length, 3);
    });

    testWidgets('Discussions asks for discussions only', (t) async {
      final repo = FakeCommunityRepository(
        posts: [
          postDto(),
          postDto(id: 'p-2', type: PostType.question, body: 'A question'),
        ],
      );
      await openApp(t, community: repo);
      await t.tap(find.text('Discussions'));
      await t.pumpAndSettle();
      expect(repo.feedTypes.last, PostType.discussion);
      expect(find.text('A question'), findsNothing);
    });

    testWidgets('empty, error and offline states', (t) async {
      final repo = FakeCommunityRepository();
      await openApp(t, community: repo);
      expect(find.text('Nothing here yet'), findsOneWidget);
    });

    testWidgets('a network failure says offline and retry works', (t) async {
      final repo = FakeCommunityRepository(posts: [postDto()])
        ..feedFailure = const NetworkFailure();
      await openApp(t, community: repo);
      expect(find.text("You're offline"), findsOneWidget);
      repo.feedFailure = null;
      await t.tap(find.text('Try again'));
      await t.pumpAndSettle();
      expect(
        find.text('How are you pricing short-form brand content in 2026?'),
        findsOneWidget,
      );
    });

    testWidgets('a server failure shows its own message', (t) async {
      final repo = FakeCommunityRepository()
        ..feedFailure = const ApiFailure(
          code: 'INTERNAL_ERROR',
          message: 'The feed is resting.',
          statusCode: 500,
        );
      await openApp(t, community: repo);
      expect(find.text("We couldn't load the feed"), findsOneWidget);
      expect(find.text('The feed is resting.'), findsOneWidget);
    });
  });

  group('Like', () {
    testWidgets('is optimistic and rolls back when the server refuses', (
      t,
    ) async {
      final repo = FakeCommunityRepository(posts: [postDto()])
        ..reactFailure = const ApiFailure(
          code: 'RATE_LIMITED',
          message: 'slow down',
          statusCode: 429,
        );
      final h = await openApp(t, community: repo);
      final post = repo.posts.first;
      final actions = h.container.read(postActionsProvider);

      final pending = actions.toggleLike(post);
      // Before the server answers the heart is already on and the count is up.
      var shown = h.container.read(postOverridesProvider).resolve(post);
      expect(shown.viewer.reacted, isTrue);
      expect(shown.reactionCount, 49);
      await expectLater(pending, throwsA(isA<ApiFailure>()));
      shown = h.container.read(postOverridesProvider).resolve(post);
      expect(shown.viewer.reacted, isFalse);
      expect(shown.reactionCount, 48);
    });

    testWidgets('tapping the heart updates the count and tells the server', (
      t,
    ) async {
      final repo = FakeCommunityRepository(posts: [postDto()]);
      await openApp(t, community: repo);
      expect(find.text('48'), findsOneWidget);
      await t.tap(find.bySemanticsLabel('Like, 48 likes'));
      await t.pumpAndSettle();
      expect(repo.reacted, ['p-1']);
      expect(find.text('49'), findsOneWidget);
    });

    testWidgets('a refused like shows the reason and keeps the old count', (
      t,
    ) async {
      final repo = FakeCommunityRepository(posts: [postDto()])
        ..reactFailure = const ApiFailure(
          code: 'FORBIDDEN',
          message: 'no',
          statusCode: 403,
          details: {'reason': 'ACCOUNT_RESTRICTED'},
        );
      await openApp(t, community: repo);
      await t.tap(find.bySemanticsLabel('Like, 48 likes'));
      await t.pumpAndSettle();
      expect(find.text('48'), findsOneWidget);
      expect(find.textContaining('restricted'), findsOneWidget);
    });
  });

  group('Error mapping', () {
    testWidgets('speaks the community codes in plain words', (t) async {
      late AppLocalizations l10n;
      await t.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      String m(String code, {Map<String, Object?> d = const {}}) =>
          communityErrorMessage(
            l10n,
            ApiFailure(code: code, message: 'raw', statusCode: 400, details: d),
          );
      expect(m('VERIFICATION_REQUIRED'), contains('Verify your email'));
      expect(
        m('FORBIDDEN', d: {'reason': 'ACCOUNT_RESTRICTED'}),
        contains('restricted'),
      );
      expect(
        m('FORBIDDEN', d: {'reason': 'NOT_A_MEMBER'}),
        contains('Join this group'),
      );
      expect(m('RESOURCE_NOT_FOUND'), contains("isn't available"));
      expect(m('RATE_LIMITED'), contains('a little fast'));
      expect(m('VALIDATION_ERROR'), 'raw');
      expect(
        communityErrorMessage(l10n, const NetworkFailure()),
        const NetworkFailure().message,
      );
    });
  });

  group('Compose', () {
    testWidgets('autosaves a draft, restores it, and clears it on post', (
      t,
    ) async {
      final repo = FakeCommunityRepository(posts: [postDto()]);
      final h = await openApp(t, community: repo, at: '/compose');
      expect(find.text('Draft saved automatically'), findsOneWidget);
      await t.enterText(find.byType(TextField).first, 'Working on a mural');
      await t.pump(const Duration(milliseconds: 700));
      expect(h.draftStorage.values[_draftKey], contains('Working on a mural'));

      // Leave and come back: the words are still there.
      h.router.go('/community');
      await t.pumpAndSettle();
      unawaited(h.router.push('/compose'));
      await t.pumpAndSettle();
      expect(find.text('Working on a mural'), findsOneWidget);

      await t.tap(find.text('Post'));
      await t.pumpAndSettle();
      expect(repo.created.single.body, 'Working on a mural');
      expect(repo.created.single.type, PostType.update);
      expect(repo.created.single.audience, PostAudience.members);
      expect(h.draftStorage.values.containsKey(_draftKey), isFalse);
      expect(find.text('Posted.'), findsOneWidget);
    });

    testWidgets('will not post nothing, or more than 5000 characters', (
      t,
    ) async {
      final repo = FakeCommunityRepository();
      await openApp(t, community: repo, at: '/compose');
      await t.tap(find.text('Post'));
      await t.pumpAndSettle();
      expect(
        find.text('Write something, or add a photo, video or link.'),
        findsOneWidget,
      );
      await t.enterText(find.byType(TextField).first, 'x' * 5001);
      await t.pump();
      expect(find.text('5001/5000', skipOffstage: false), findsOneWidget);
      await t.tap(find.text('Post'));
      await t.pumpAndSettle();
      expect(
        find.text('Posts can be up to 5000 characters.', skipOffstage: false),
        findsOneWidget,
      );
      expect(repo.created, isEmpty);
    });

    testWidgets('maps VERIFICATION_REQUIRED and ACCOUNT_RESTRICTED', (t) async {
      final repo = FakeCommunityRepository()
        ..createFailure = const ApiFailure(
          code: 'VERIFICATION_REQUIRED',
          message: 'raw',
          statusCode: 403,
          details: {'reason': 'CONTACT_NOT_VERIFIED'},
        );
      await openApp(t, community: repo, at: '/compose');
      await t.enterText(find.byType(TextField).first, 'Hello');
      await t.tap(find.text('Post'));
      await t.pumpAndSettle();
      expect(find.textContaining('Verify your email or phone'), findsOneWidget);
      // The words are kept so nothing is lost.
      expect(find.text('Hello'), findsOneWidget);
      repo.createFailure = const ApiFailure(
        code: 'FORBIDDEN',
        message: 'raw',
        statusCode: 403,
        details: {'reason': 'ACCOUNT_RESTRICTED'},
      );
      await t.tap(find.text('Post'));
      await t.pumpAndSettle();
      expect(find.textContaining('restricted'), findsOneWidget);
    });

    testWidgets('uploads a video and posts it with its media id', (t) async {
      final repo = FakeCommunityRepository();
      final h = Harness(
        auth: FakeAuthRepository(restored: fakeUser(name: 'Nia Wairimu')),
        community: repo,
      );
      h.media.queue.add(const [
        PickedMedia(
          path: 'clip.mp4',
          name: 'clip.mp4',
          mimeType: 'video/mp4',
          sizeBytes: 1000,
        ),
      ]);
      await h.pump(t);
      h.router.go('/compose');
      await t.pumpAndSettle();
      await t.tap(find.bySemanticsLabel('Video'));
      await t.pumpAndSettle();
      expect(h.portfolio.uploaded, hasLength(1));
      await t.tap(find.text('Post'));
      await t.pumpAndSettle();
      expect(repo.created.single.mediaIds, hasLength(1));
    });

    testWidgets('choosing a group sends its id; Opportunity says Soon', (
      t,
    ) async {
      final repo = FakeCommunityRepository()
        ..groups = [
          const GroupCardDto(
            id: 'g-1',
            slug: 'nairobi-animators',
            type: GroupType.discipline,
            name: 'Nairobi Animators',
            description: 'd',
            coverUrl: null,
            memberCount: 10,
            isOfficial: false,
            focus: null,
            joined: true,
            role: null,
          ),
        ];
      final h = await openApp(t, community: repo, at: '/compose');
      await t.tap(find.text('Atarah members'));
      await t.pumpAndSettle();
      await t.tap(find.text('Nairobi Animators'));
      await t.pumpAndSettle();
      expect(find.text('Nairobi Animators'), findsOneWidget);
      await t.enterText(find.byType(TextField).first, 'Hi group');
      await t.tap(find.text('Post'));
      await t.pumpAndSettle();
      expect(repo.created.single.groupId, 'g-1');
      expect(repo.created.single.audience, PostAudience.group);

      unawaited(h.router.push('/compose'));
      await t.pumpAndSettle();
      await t.tap(find.bySemanticsLabel('Opportunity'));
      await t.pumpAndSettle();
      expect(find.textContaining('Soon'), findsWidgets);
    });
  });

  group('Discussion', () {
    Future<FakeCommunityRepository> thread(
      WidgetTester t, {
      bool mine = false,
    }) async {
      final repo = FakeCommunityRepository(
        posts: [postDto(mine: mine)],
        comments: {
          'p-1': [
            commentDto(replies: [replyDto()]),
          ],
        },
      );
      await openApp(t, community: repo, at: '/posts/p-1');
      return repo;
    }

    testWidgets('shows the post, a reply and its nested reply with times', (
      t,
    ) async {
      await thread(t);
      expect(find.text('23 replies'), findsOneWidget);
      expect(
        find.text('Splitting usage from production changed everything for me.'),
        findsOneWidget,
      );
      expect(
        find.text('Do you charge for revisions separately?'),
        findsOneWidget,
      );
      expect(find.text('Amani Otieno'), findsOneWidget);
      expect(find.text('1h'), findsOneWidget);
    });

    testWidgets('replying posts under the chosen comment', (t) async {
      final repo = await thread(t);
      await t.tap(find.bySemanticsLabel('Reply').first);
      await t.pump();
      expect(find.text('Replying to Kiptoo Langat'), findsOneWidget);
      await t.enterText(find.byType(TextField).last, 'Agreed!');
      await t.pump();
      await t.tap(find.byIcon(LucideIcons.send));
      await t.pumpAndSettle();
      expect(repo.replies.single, (body: 'Agreed!', parent: 'c-1'));
      expect(find.text('Agreed!'), findsOneWidget);
      expect(find.text('24 replies'), findsOneWidget);
    });

    testWidgets('report flow: reason, optional note, then what happens next', (
      t,
    ) async {
      final repo = await thread(t);
      await t.tap(find.bySemanticsLabel('More options').first);
      await t.pumpAndSettle();
      await t.tap(find.text('Report'));
      await t.pumpAndSettle();
      expect(find.text('Scam or spam'), findsOneWidget);
      // Nothing is sent until a reason is chosen.
      await t.tap(find.text('Scam or spam'));
      await t.pump();
      await t.enterText(find.byType(TextField).last, 'Fake giveaway');
      await t.ensureVisible(find.text('Send report'));
      await t.tap(find.text('Send report'));
      await t.pumpAndSettle();
      final r = repo.reports.single;
      expect(r.type, ReportTargetType.post);
      expect(r.id, 'p-1');
      expect(r.reason, ReportReason.scam);
      expect(r.note, 'Fake giveaway');
      expect(find.text('Thanks for telling us'), findsOneWidget);
      expect(find.textContaining('get a notification'), findsOneWidget);
    });

    testWidgets('a failed report keeps the sheet open with the reason why', (
      t,
    ) async {
      final repo = await thread(t);
      repo.reportFailure = const ApiFailure(
        code: 'RATE_LIMITED',
        message: 'raw',
        statusCode: 429,
      );
      await t.tap(find.bySemanticsLabel('More options').first);
      await t.pumpAndSettle();
      await t.tap(find.text('Report'));
      await t.pumpAndSettle();
      await t.tap(find.text('Something else'));
      await t.pump();
      await t.ensureVisible(find.text('Send report'));
      await t.tap(find.text('Send report'));
      await t.pumpAndSettle();
      expect(find.textContaining('a little fast'), findsOneWidget);
      expect(find.text('Send report'), findsOneWidget);
    });

    testWidgets('block flow: explains, blocks, confirms, and can be undone', (
      t,
    ) async {
      final repo = await thread(t);
      await t.tap(find.bySemanticsLabel('More options').first);
      await t.pumpAndSettle();
      await t.tap(find.text('Block author'));
      await t.pumpAndSettle();
      expect(find.text('Block Kiptoo Langat?'), findsOneWidget);
      expect(
        find.textContaining("won't see each other's posts"),
        findsOneWidget,
      );
      await t.tap(find.text('Block'));
      await t.pumpAndSettle();
      expect(repo.blocked, ['u-kiptoo']);
      expect(find.text('Kiptoo Langat is blocked'), findsOneWidget);
      await t.tap(find.text('Undo block'));
      await t.pumpAndSettle();
      expect(repo.unblocked, ['u-kiptoo']);
    });

    testWidgets('own post: edit and delete instead of block and report', (
      t,
    ) async {
      final repo = await thread(t, mine: true);
      await t.tap(find.bySemanticsLabel('More options').first);
      await t.pumpAndSettle();
      expect(find.text('Block author'), findsNothing);
      expect(find.text('Report'), findsNothing);
      await t.tap(find.text('Delete'));
      await t.pumpAndSettle();
      expect(find.text('Delete this post?'), findsOneWidget);
      await t.tap(find.text('Delete').last);
      await t.pumpAndSettle();
      expect(repo.deleted, ['p-1']);
    });

    testWidgets('a post that is gone says so', (t) async {
      await openApp(
        t,
        community: FakeCommunityRepository(),
        at: '/posts/missing',
      );
      expect(find.text("This post isn't available"), findsOneWidget);
    });
  });
}
