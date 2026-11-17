import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/fake_discover.dart';
import '../support/fake_onboarding.dart';
import '../support/fake_portfolio.dart';
import '../support/fake_profile.dart';
import '../support/fakes.dart';

/// One golden per built screen, per appearance, on a 390x844 phone at 1x, rendered through the real app and
/// router with the same fakes as the feature tests. Regenerate after intentional visual changes:
/// `flutter test --update-goldens test/features/screen_goldens_test.dart`.
void main() {
  for (final appearance in AtAppearance.values) {
    final dark = appearance == AtAppearance.dark;

    MeDto user() => fakeUser(
      name: 'Nia Wairimu',
      appearance: dark ? MeDtoAppearance.dark : MeDtoAppearance.light,
    );

    Future<void> shoot(
      WidgetTester t,
      String name, {
      required String at,
      bool signedIn = true,
      FakeOnboardingRepository? onboarding,
      FakeDiscoverRepository? discover,
      FakePortfolioRepository? portfolio,
      FakeProfileRepository? profile,
      Future<void> Function(WidgetTester t)? act,
    }) async {
      final h = Harness(
        appearance: appearance,
        auth: signedIn ? FakeAuthRepository(restored: user()) : null,
        onboarding: onboarding,
        discover: discover,
        portfolio: portfolio,
        profile: profile,
      );
      await h.pump(t);
      h.router.go(at);
      // Some screens animate forever (splash); settle if it can, else take a few frames.
      try {
        await t.pumpAndSettle(
          const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 3),
        );
      } on Object {
        await t.pump(const Duration(milliseconds: 300));
      }
      if (act != null) await act(t);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/screens/$name.${appearance.name}.png'),
      );
    }

    final discover = FakeDiscoverRepository(
      home: homeDto(
        completion: 70,
        unread: 2,
        article: articleCard(),
        creatives: [
          creativeCard(verified: true, open: true),
          creativeCard(
            handle: 'otieno',
            name: 'Otieno Ouma',
            discipline: 'Photography',
          ),
        ],
      ),
      creatives: [
        creativeCard(verified: true, open: true, reason: 'Same discipline'),
        creativeCard(
          handle: 'otieno',
          name: 'Otieno Ouma',
          discipline: 'Photography',
        ),
        creativeCard(
          handle: 'zawadi',
          name: 'Zawadi Achieng',
          discipline: 'Music',
          open: true,
        ),
      ],
      articles: [
        articleCard(),
        articleCard(
          id: 'a-2',
          slug: 'b',
          title: 'A partner piece',
          source: 'PARTNER',
          sourceLabel: 'Creative Hub',
        ),
      ],
      articleDetails: {'pricing-illustration': articleDto()},
      creativeHits: [creativeHit('wanjiku', 'Wanjiku Njeri', verified: true)],
      articleHits: [
        articleHit(
          'pricing-illustration',
          'How to price commissioned illustration',
        ),
      ],
      recents: const ['animation', 'photographer nairobi'],
    );

    FakePortfolioRepository portfolio() => FakePortfolioRepository()
      ..projects.addAll([
        projectDto(
          id: 'a',
          title: 'Mama Mboga',
          featured: true,
          skills: const [
            TaxonomyItemDto(id: 'k-1', slug: 'animation', name: 'Animation'),
          ],
        ),
        projectDto(id: 'b', title: 'Zine issue 3', category: 'PUBLICATION'),
        projectDto(id: 'c', title: 'Half done', status: 'DRAFT'),
      ])
      ..skills.addAll([
        skillEntry('s1', 'Animation', level: 'ADVANCED', projects: 2),
        skillEntry('s2', 'Colour', source: 'VERIFIED'),
      ])
      ..skillCatalogue.addAll(const [
        TaxonomyItemDto(id: 'k-1', slug: 'animation', name: 'Animation'),
      ])
      ..experience.addAll(const [
        ExperienceDto(
          id: 'x1',
          title: 'Senior animator',
          organisation: 'Kaka Studios',
          startDate: '2024-02-01',
          current: true,
        ),
        ExperienceDto(
          id: 'x2',
          title: 'Animator',
          organisation: 'Studio Two',
          startDate: '2022-01-01',
          endDate: '2024-01-01',
          current: false,
        ),
      ])
      ..achievements.addAll(const [
        AchievementDto(
          id: 'a1',
          type: AchievementDtoType.certificate,
          title: 'Skill Labs: Colour',
          source: AchievementDtoSource.system,
        ),
        AchievementDto(
          id: 'a2',
          type: AchievementDtoType.award,
          title: 'Best Short',
          source: AchievementDtoSource.manual,
        ),
      ])
      ..services.addAll(const [
        ServiceDto(
          id: 's1',
          title: 'Storyboards',
          priceType: ServiceDtoPriceType.onRequest,
          status: ServiceDtoStatus.profileOnly,
        ),
      ]);

    group('screens, ${appearance.name}', () {
      testWidgets(
        'splash',
        (t) => shoot(t, 'splash', at: '/splash', signedIn: false),
      );
      testWidgets(
        'welcome',
        (t) => shoot(t, 'welcome', at: '/welcome', signedIn: false),
      );
      testWidgets(
        'sign in',
        (t) => shoot(t, 'signin', at: '/signin', signedIn: false),
      );
      testWidgets(
        'verify',
        (t) => shoot(
          t,
          'verify',
          at: '/verify?identifier=nia%40example.com',
          signedIn: false,
        ),
      );
      testWidgets(
        'onboarding intro',
        (t) => shoot(
          t,
          'ob_intro',
          at: '/onboarding',
          onboarding: FakeOnboardingRepository(),
        ),
      );
      testWidgets(
        'onboarding discipline',
        (t) => shoot(
          t,
          'ob_discipline',
          at: '/onboarding',
          onboarding: FakeOnboardingRepository(
            step: OnboardingStateDtoStep.discipline,
          ),
        ),
      );
      testWidgets(
        'onboarding done',
        (t) => shoot(
          t,
          'ob_done',
          at: '/onboarding',
          onboarding: FakeOnboardingRepository(
            step: OnboardingStateDtoStep.photo,
          )..disciplineId = 'd-animation',
          // Finish the last step, which shows the completion screen.
          act: (t) async {
            await tapText(t, 'Finish', last: true);
          },
        ),
      );
      testWidgets(
        'home',
        (t) => shoot(t, 'home', at: '/home', discover: discover),
      );
      testWidgets(
        'explore',
        (t) => shoot(t, 'explore', at: '/explore', discover: discover),
      );
      testWidgets(
        'search',
        (t) => shoot(t, 'search', at: '/search', discover: discover),
      );
      testWidgets(
        'filters sheet',
        (t) => shoot(
          t,
          'filters',
          at: '/explore',
          discover: discover,
          act: (t) async {
            await t.tap(find.bySemanticsLabel('Filters'));
            await t.pumpAndSettle();
          },
        ),
      );
      testWidgets(
        'article',
        (t) => shoot(
          t,
          'article',
          at: '/articles/pricing-illustration',
          discover: discover,
        ),
      );
      testWidgets('profile', (t) => shoot(t, 'profile', at: '/profile'));
      testWidgets('passport', (t) => shoot(t, 'passport', at: '/passport'));
      testWidgets('public creative profile', (t) {
        final p = FakeProfileRepository()
          ..creatives['amina'] = (_) => publicProfile();
        return shoot(t, 'creative', at: '/creatives/amina', profile: p);
      });
      testWidgets(
        'portfolio',
        (t) => shoot(t, 'portfolio', at: '/portfolio', portfolio: portfolio()),
      );
      testWidgets(
        'project',
        (t) => shoot(t, 'project', at: '/projects/a', portfolio: portfolio()),
      );
      testWidgets(
        'skills',
        (t) => shoot(t, 'skills', at: '/skills', portfolio: portfolio()),
      );
      testWidgets(
        'experience',
        (t) =>
            shoot(t, 'experience', at: '/experience', portfolio: portfolio()),
      );
      testWidgets(
        'achievements',
        (t) => shoot(
          t,
          'achievements',
          at: '/achievements',
          portfolio: portfolio(),
        ),
      );
      testWidgets(
        'services',
        (t) => shoot(t, 'services', at: '/services', portfolio: portfolio()),
      );
    });
  }
}
