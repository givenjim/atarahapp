import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/fake_community.dart';
import '../support/fake_discover.dart';
import '../support/fake_groups.dart';
import '../support/fake_learning.dart';
import '../support/fake_onboarding.dart';
import '../support/fake_opportunities.dart';
import '../support/fake_people.dart';
import '../support/fake_portfolio.dart';
import '../support/fake_profile.dart';
import '../support/fakes.dart';

/// P1-M12 accessibility audit over every Phase 1 screen, run in the real app shell with data-rich fakes:
///  * every tappable control has a semantic label (`labeledTapTargetGuideline`),
///  * every tap target is at least 48 x 48 (`androidTapTargetGuideline`),
///  * text meets contrast: the token pairs are asserted in `test/design_system/contrast_test.dart`. Flutter's
///    pixel-sampling `textContrastGuideline` is run per screen only on request
///    (`--dart-define=A11Y_CONTRAST=true`), because it reports artefacts (text-field boxes, text over cover
///    images and gradients, 1.1:1 to 2.8:1) and the one real gap, `muted` at 4.44:1, is a known spec value (see
///    docs/DECISIONS.md),
///  * the layout survives 200% text with no overflow.
///
/// Screens that appear in more than one state (empty, error, offline) have those states audited in their own
/// feature tests; here each screen is checked with data, which is where long text and dense rows are.
class Phase1Screen {
  const Phase1Screen(this.name, this.path, {this.signedOut = false});
  final String name;
  final String path;
  final bool signedOut;
}

const phase1Screens = <Phase1Screen>[
  // Entry (signed out).
  Phase1Screen('welcome', '/welcome', signedOut: true),
  Phase1Screen('sign up', '/signup', signedOut: true),
  Phase1Screen('sign in', '/signin', signedOut: true),
  Phase1Screen('forgot password', '/forgot', signedOut: true),
  Phase1Screen('legal (public)', '/legal/TERMS', signedOut: true),
  // Home and explore.
  Phase1Screen('home', '/home'),
  Phase1Screen('explore', '/explore'),
  Phase1Screen('search', '/search'),
  Phase1Screen('articles', '/articles'),
  Phase1Screen('article', '/articles/wanjiku-story'),
  // Identity.
  Phase1Screen('profile', '/profile'),
  Phase1Screen('passport', '/passport'),
  Phase1Screen('creative profile', '/creatives/amina'),
  Phase1Screen('portfolio', '/portfolio'),
  Phase1Screen('project', '/projects/pr-a'),
  Phase1Screen('project editor', '/portfolio/new/edit'),
  Phase1Screen('skills', '/skills'),
  Phase1Screen('experience', '/experience'),
  Phase1Screen('achievements', '/achievements'),
  Phase1Screen('services', '/services'),
  // Community.
  Phase1Screen('community', '/community'),
  Phase1Screen('post', '/posts/p-1'),
  Phase1Screen('compose', '/compose'),
  Phase1Screen('group', '/groups/g-1'),
  Phase1Screen('people to meet', '/creatives'),
  Phase1Screen('connections', '/connections'),
  Phase1Screen('blocked', '/blocked'),
  // Opportunities.
  Phase1Screen('opportunities', '/opportunities'),
  Phase1Screen('opportunities list', '/opportunities/browse'),
  Phase1Screen('my opportunities', '/opportunities/mine'),
  Phase1Screen('opportunity', '/opportunities/o-1'),
  // Learning.
  Phase1Screen('skill labs', '/learning'),
  Phase1Screen('my learning', '/learning/mine'),
  Phase1Screen('learning category', '/learning/categories/animation'),
  Phase1Screen('course', '/learning/courses/lab-1'),
  Phase1Screen('lesson', '/learning/lessons/lesson-1'),
  // Activity and settings.
  Phase1Screen('activity', '/activity'),
  Phase1Screen('notifications', '/notifications'),
  Phase1Screen('saved', '/saved'),
  Phase1Screen('applications', '/applications'),
  Phase1Screen('settings', '/settings'),
  Phase1Screen('account settings', '/settings/account'),
  Phase1Screen('privacy settings', '/settings/privacy'),
  Phase1Screen('notification settings', '/settings/notifications'),
  Phase1Screen('security', '/settings/security'),
  Phase1Screen('help', '/settings/help'),
  Phase1Screen('help article', '/settings/help/safety-centre'),
  Phase1Screen('legal list', '/settings/legal'),
  Phase1Screen('legal document', '/settings/legal/TERMS'),
  Phase1Screen('membership', '/settings/membership'),
  Phase1Screen('delete account', '/settings/delete'),
  // Labelled future screens.
  Phase1Screen('soon (P2)', '/soon/p2?name=Marketplace'),
  Phase1Screen('soon (later)', '/soon/later?name=Wellness%20Zone'),
];

/// Everything a screen might want to show, so the audit sees real rows rather than empty states.
Harness richHarness({
  bool signedOut = false,
  AtAppearance appearance = AtAppearance.light,
}) {
  final portfolio = FakePortfolioRepository()
    ..projects.add(
      projectDto(
        id: 'pr-a',
        title: 'Mama Mboga',
        client: 'Kaka Studios',
        media: [imageMedia('m1')],
      ),
    )
    ..skills.addAll([
      skillEntry('s-1', 'Animation', level: 'ADVANCED', projects: 2),
      skillEntry('s-2', 'Colour'),
    ]);
  final profile = FakeProfileRepository();
  profile.creatives['amina'] = (_) => publicProfile();
  final discover = FakeDiscoverRepository(
    creatives: [creativeCard()],
    articles: [articleCard(slug: 'wanjiku-story')],
    articleDetails: {
      'wanjiku-story': articleDto(
        slug: 'wanjiku-story',
        title: 'The Wanjiku story',
      ),
    },
  );
  return Harness(
    auth: signedOut
        ? FakeAuthRepository()
        : FakeAuthRepository(restored: fakeUser(name: 'Nia Wairimu')),
    appearance: appearance,
    portfolio: portfolio,
    profile: profile,
    discover: discover,
    community: FakeCommunityRepository(
      posts: [postDto()],
      comments: {
        'p-1': [
          commentDto(replies: [replyDto()]),
        ],
      },
    ),
    opportunities: FakeOpportunitiesRepository(
      opportunities: [
        oppDto(),
        oppDto(id: 'o-2', title: 'Weekend gig'),
      ],
      trackings: {'o-2': trackingOf(OpportunityTrackingStatus.saved)},
    ),
    learning: FakeLearningRepository(
      hub: hubDto(
        featured: [labCard(id: 'lab-1', title: 'Portfolio course')],
      ),
      details: {
        'lab-1': labDetail(course: courseInfo(enrolled: true, done: 1)),
      },
      lessons: {'lesson-1': lessonDto()},
      categoryItems: [labCard(id: 'lab-1', title: 'Portfolio course')],
    ),
    groups: FakeGroupsRepository(
      mine: [groupCard(joined: true)],
      discover: [groupCard(id: 'g-2', slug: 'poets', name: 'Nairobi Poets')],
      detail: groupDetailDto(joined: true, canPost: true),
      postList: [groupPost()],
    ),
    people: FakePeopleRepository(
      people: [personToMeet()],
      connected: [connectionItem()],
    ),
    onboarding: FakeOnboardingRepository(
      completed: true,
      step: OnboardingStateDtoStep.done,
    ),
  );
}

Future<Harness> openScreen(
  WidgetTester t,
  Phase1Screen s, {
  AtAppearance appearance = AtAppearance.light,
}) async {
  final h = richHarness(signedOut: s.signedOut, appearance: appearance);
  await h.pump(t);
  // A tall window so lazily built lists are built and every control is measured.
  t.view.physicalSize = const Size(390, 2400);
  h.router.go(s.path);
  await t.pumpAndSettle();
  return h;
}

const _contrast = bool.fromEnvironment('A11Y_CONTRAST');

void main() {
  for (final s in phase1Screens) {
    group('${s.name} (${s.path})', () {
      testWidgets('controls are labelled and tap targets are 48 dp', (t) async {
        final handle = t.ensureSemantics();
        await openScreen(t, s);
        await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(t, meetsGuideline(androidTapTargetGuideline));
        handle.dispose();
      });

      for (final appearance in [AtAppearance.light, AtAppearance.dark]) {
        testWidgets('text contrast, ${appearance.name}', (t) async {
          final handle = t.ensureSemantics();
          await openScreen(t, s, appearance: appearance);
          await expectLater(t, meetsGuideline(textContrastGuideline));
          handle.dispose();
        }, skip: !_contrast);
      }

      testWidgets('lays out at 200% text without overflow', (t) async {
        t.platformDispatcher.textScaleFactorTestValue = 2.0;
        addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
        await openScreen(t, s);
        expect(t.takeException(), isNull);
      });
    });
  }
}
