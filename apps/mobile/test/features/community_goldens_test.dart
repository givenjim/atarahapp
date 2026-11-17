import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/fake_community.dart';
import '../support/fakes.dart';

/// Community feed, discussion and composer in both appearances, 390x844 at 1x. Regenerate after intentional
/// visual changes: `flutter test --update-goldens test/features/community_goldens_test.dart`.
void main() {
  for (final appearance in AtAppearance.values) {
    final dark = appearance == AtAppearance.dark;

    Future<void> shoot(WidgetTester t, String name, String at) async {
      final repo = FakeCommunityRepository(
        posts: [
          postDto(),
          postDto(
            id: 'p-2',
            type: PostType.update,
            body: 'Wrapped a week documenting fishing families in Shimoni. First edit is up in my portfolio.',
            by: author(id: 'u-zuri', name: 'Zuri Mwangi', verified: true),
            likes: 31,
            replies: 4,
            reacted: true,
            link: const PostLinkPreviewDto(
              url: 'https://example.com/shimoni',
              title: 'Shimoni Fishers',
              description: 'A photo essay',
              image: null,
              siteName: 'example.com',
            ),
          ),
          postDto(
            id: 'p-3',
            type: PostType.announcement,
            body: 'Skill verification opens on 1 November.',
            announcement: true,
            likes: 212,
            replies: 41,
          ),
          postDto(
            id: 'p-4',
            type: PostType.question,
            body: 'Anyone recommend a studio in Westlands under KES 3,000/hr?',
            by: author(id: 'u-amani', name: 'Amani Otieno'),
            likes: 19,
            replies: 9,
          ),
        ],
        comments: {
          'p-1': [
            commentDto(replies: [replyDto()]),
            commentDto(
              id: 'c-2',
              body: 'Usage rights as a separate line is the way.',
              by: author(id: 'u-wanjiku', name: 'Wanjiku Njeri'),
            ),
          ],
        },
      );
      final h = Harness(
        appearance: appearance,
        auth: FakeAuthRepository(
          restored: fakeUser(
            name: 'Nia Wairimu',
            appearance: dark ? MeDtoAppearance.dark : MeDtoAppearance.light,
          ),
        ),
        community: repo,
      );
      await h.pump(t);
      h.router.go(at);
      await t.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/screens/$name.${appearance.name}.png'),
      );
    }

    testWidgets('community ${appearance.name}', (t) async {
      await shoot(t, 'community', '/community');
    });
    testWidgets('post ${appearance.name}', (t) async {
      await shoot(t, 'community_post', '/posts/p-1');
    });
    testWidgets('compose ${appearance.name}', (t) async {
      await shoot(t, 'community_compose', '/compose');
    });
  }
}
