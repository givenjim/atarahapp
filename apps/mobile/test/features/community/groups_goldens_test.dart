import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_groups.dart';
import 'groups_test.dart' show GroupsHarness;

/// Groups tab and group screen, light and dark, 390x844 at 1x. Regenerate after intentional visual changes:
/// `flutter test --update-goldens test/features/community/groups_goldens_test.dart`.
void main() {
  for (final appearance in AtAppearance.values) {
    final dark = appearance == AtAppearance.dark;

    testWidgets('groups tab ${appearance.name}', (t) async {
      final repo = FakeGroupsRepository(
        mine: [
          groupCard(
            id: 'm-1',
            slug: 'kenya-illustrators',
            name: 'Kenya Illustrators',
            joined: true,
            members: 860,
          ),
          groupCard(
            id: 'm-2',
            slug: 'film-makers',
            name: 'Film Makers KE',
            joined: true,
            members: 412,
          ),
        ],
        discover: [
          groupCard(),
          groupCard(
            id: 'g-2',
            slug: 'mombasa-makers',
            name: 'Mombasa Makers',
            type: GroupType.location,
            members: 214,
          ),
          groupCard(
            id: 'g-3',
            slug: 'joined-one',
            name: 'Typography Club',
            type: GroupType.interest,
            joined: true,
            members: 98,
          ),
        ],
      );
      await GroupsHarness(repo, dark: dark).pump(t);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/groups_tab.${appearance.name}.png'),
      );
    });

    testWidgets('group ${appearance.name}', (t) async {
      final repo = FakeGroupsRepository(
        detail: groupDetailDto(
          joined: true,
          canPost: true,
          official: true,
          pinned: groupPost(
            id: 'pin',
            body: 'Monthly crit night, 24 Oct at 6pm. Bring 30 seconds of work in progress.',
          ),
        ),
        postList: [
          groupPost(),
          groupPost(
            id: 'p-2',
            author: 'Kiptoo Langat',
            body: 'Who is going to Nairobi Animation Week?',
            replies: 8,
          ),
        ],
      );
      await GroupsHarness(repo, dark: dark).pump(t, at: '/groups/g-1');
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/group.${appearance.name}.png'),
      );
    });
  }
}
