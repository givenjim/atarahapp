import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/l10n/app_localizations.dart';
import 'package:atarah/core/routing/routes.dart';
import 'package:atarah/features/mentorship/mentor_apply_screen.dart';
import 'package:atarah/features/mentorship/mentor_manage_screens.dart';
import 'package:atarah/features/mentorship/mentor_screen.dart';
import 'package:atarah/features/mentorship/mentor_tools_screen.dart';
import 'package:atarah/features/mentorship/mentors_list_screen.dart';
import 'package:atarah/features/mentorship/mentorship_common.dart';
import 'package:atarah/features/mentorship/mentorship_hub_screen.dart';
import 'package:atarah/features/mentorship/mentorship_repository.dart';
import 'package:atarah/features/onboarding/onboarding_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../support/fake_mentorship.dart';

/// Pumps [home] at `/` in a small router that records where navigation went (every other path is a stub).
Future<List<String>> openAt(
  WidgetTester t,
  Widget home,
  FakeMentorshipRepository repo,
) async {
  t.view.physicalSize = const Size(390, 1400);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  final visited = <String>[];
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => home),
      GoRoute(
        path: '/:a',
        builder: (_, s) {
          visited.add(s.uri.toString());
          return Scaffold(body: Text('stub ${s.uri}'));
        },
        routes: [
          GoRoute(
            path: ':b',
            builder: (_, s) {
              visited.add(s.uri.toString());
              return Scaffold(body: Text('stub ${s.uri}'));
            },
            routes: [
              GoRoute(
                path: ':c',
                builder: (_, s) {
                  visited.add(s.uri.toString());
                  return Scaffold(body: Text('stub ${s.uri}'));
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
  await t.pumpWidget(
    ProviderScope(
      overrides: [
        mentorshipRepositoryProvider.overrideWithValue(repo),
        disciplinesProvider.overrideWith((ref) async => const []),
      ],
      child: MaterialApp.router(
        theme: AtTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await t.pumpAndSettle();
  return visited;
}

MentorshipHomeDto homeOf({
  bool canBook = false,
  bool isMentor = false,
  List<MentorCardDto> top = const [],
}) => MentorshipHomeDto(canBook: canBook, isMentor: isMentor, topMentors: top);

void main() {
  group('formatting', () {
    test('formats minor units as KES with grouping', () {
      expect(formatMoney(150000, 'KES'), 'KES 1,500');
      expect(formatMoney(150050, 'KES'), 'KES 1,500.50');
      expect(formatMoney(0, 'KES'), 'KES 0');
    });

    test('parses a typed price back to minor units', () {
      expect(parseMajorToMinor('1,500'), 150000);
      expect(parseMajorToMinor('12.5'), 1250);
      expect(parseMajorToMinor('abc'), isNull);
      expect(parseMajorToMinor('-3'), isNull);
      expect(minorToMajorText(150000), '1500');
      expect(minorToMajorText(1250), '12.50');
    });

    test('formats a minute of the day', () {
      expect(formatMinute(9 * 60 + 5), '09:05');
      expect(formatMinute(0), '00:00');
    });
  });

  group('Mentorship hub', () {
    testWidgets(
      'shows how it works, the Pro pill for Free members and mentors',
      (t) async {
        final repo = FakeMentorshipRepository(
          homeDto: homeOf(top: [mentorCard()]),
        );
        await openAt(t, const MentorshipHubScreen(), repo);
        expect(find.text('Mentorship'), findsOneWidget);
        expect(find.byType(AtProPill), findsOneWidget);
        expect(find.text('How it works'), findsOneWidget);
        expect(find.text('Wanjiru Kamau'), findsOneWidget);
        expect(find.text('From KES 1,500'), findsOneWidget);
        expect(find.text('Find a mentor'), findsWidgets);
      },
    );

    testWidgets('has a real empty state before any mentor is approved', (
      t,
    ) async {
      final repo = FakeMentorshipRepository(homeDto: homeOf(canBook: true));
      await openAt(t, const MentorshipHubScreen(), repo);
      expect(find.byType(AtProPill), findsNothing);
      expect(find.text('No mentors yet'), findsOneWidget);
    });

    testWidgets('opens a mentor from the carousel', (t) async {
      final repo = FakeMentorshipRepository(
        homeDto: homeOf(top: [mentorCard(id: 'abc')]),
      );
      final visited = await openAt(t, const MentorshipHubScreen(), repo);
      await t.tap(find.text('Wanjiru Kamau'));
      await t.pumpAndSettle();
      expect(visited, contains('/mentors/abc'));
    });

    testWidgets('mentors see Mentor tools, others see Become a mentor', (
      t,
    ) async {
      final repo = FakeMentorshipRepository(homeDto: homeOf(isMentor: true));
      await openAt(t, const MentorshipHubScreen(), repo);
      expect(find.text('Mentor tools'), findsOneWidget);
      expect(find.text('Become a mentor'), findsNothing);
    });
  });

  group('Directory', () {
    testWidgets('chips send filters to the server and show the cards', (
      t,
    ) async {
      final repo = FakeMentorshipRepository(mentors: [mentorCard()]);
      await openAt(t, const MentorsListScreen(), repo);
      expect(repo.listCalls.last.verified, isFalse);
      expect(find.text('Wanjiru Kamau'), findsOneWidget);
      expect(find.textContaining('Next:'), findsOneWidget);

      await t.tap(find.text('Verified'));
      await t.pumpAndSettle();
      expect(repo.listCalls.last.verified, isTrue);

      await t.tap(find.text('Available this week'));
      await t.pumpAndSettle();
      expect(repo.listCalls.last.availableThisWeek, isTrue);

      final chips = find.descendant(
        of: find.byType(ListView).first,
        matching: find.byType(Scrollable),
      );
      await t.drag(chips, const Offset(-400, 0));
      await t.pumpAndSettle();
      await t.tap(find.text('Under KES 2,000'));
      await t.pumpAndSettle();
      expect(repo.listCalls.last.maxPriceMinor, mentorPriceCapMinor);

      await t.drag(chips, const Offset(-400, 0));
      await t.pumpAndSettle();
      await t.tap(find.text('Video call'));
      await t.pumpAndSettle();
      expect(repo.listCalls.last.videoCall, isTrue);
    });

    testWidgets('the filters sheet changes the sort', (t) async {
      final repo = FakeMentorshipRepository(mentors: [mentorCard()]);
      await openAt(t, const MentorsListScreen(), repo);
      await t.tap(find.byIcon(LucideIcons.slidersHorizontal));
      await t.pumpAndSettle();
      await t.tap(find.text('Lowest price'));
      await t.pumpAndSettle();
      await t.tap(find.text('Show mentors'));
      await t.pumpAndSettle();
      expect(repo.listCalls.last.sort, MentorSort.price);
    });

    testWidgets('no matches shows an empty state with a way back', (t) async {
      final repo = FakeMentorshipRepository();
      await openAt(t, const MentorsListScreen(), repo);
      expect(find.text('No mentors match'), findsOneWidget);
    });
  });

  group('Mentor profile', () {
    testWidgets('a Free member is offered the Pro gate, not booking', (
      t,
    ) async {
      final repo = FakeMentorshipRepository(detailDto: mentorDetail());
      final visited = await openAt(
        t,
        const MentorScreen(mentorId: 'm-1'),
        repo,
      );
      expect(find.text('Choose a session'), findsOneWidget);
      expect(find.text('Portfolio review'), findsOneWidget);
      expect(find.text('Unlock mentorship with Pro'), findsOneWidget);
      expect(find.textContaining('Book session'), findsNothing);
      await t.tap(find.text('Unlock mentorship with Pro'));
      await t.pumpAndSettle();
      expect(visited, contains(Routes.mentorPremiumPath('m-1')));
    });

    testWidgets('a Pro member books the chosen session', (t) async {
      final repo = FakeMentorshipRepository(
        detailDto: mentorDetail(allowed: true, requiresPro: false),
      );
      final visited = await openAt(
        t,
        const MentorScreen(mentorId: 'm-1'),
        repo,
      );
      expect(find.text('Book session · KES 1,500'), findsOneWidget);
      await t.tap(find.text('Career chat'));
      await t.pumpAndSettle();
      expect(find.text('Book session · KES 1,000'), findsOneWidget);
      await t.tap(find.text('Book session · KES 1,000'));
      await t.pumpAndSettle();
      // Booking is P2-M5: until then the button opens the labelled "Soon" screen.
      expect(visited.any((v) => v.startsWith('/soon/p2')), isTrue);
    });

    testWidgets('the premium gate screen explains Pro', (t) async {
      final repo = FakeMentorshipRepository();
      await openAt(t, const MentorPremiumScreen(mentorId: 'm-1'), repo);
      expect(find.text('Mentorship is part of Pro'), findsWidgets);
    });

    testWidgets('your own profile has no booking button', (t) async {
      final repo = FakeMentorshipRepository(
        detailDto: mentorDetail(requiresPro: false, isSelf: true),
      );
      await openAt(t, const MentorScreen(mentorId: 'm-1'), repo);
      expect(
        find.text('This is how members see your profile.'),
        findsOneWidget,
      );
      expect(find.text('Unlock mentorship with Pro'), findsNothing);
    });
  });

  group('Mentor tools', () {
    testWidgets('a member who is not a mentor sees how to apply', (t) async {
      final repo = FakeMentorshipRepository();
      final visited = await openAt(t, const MentorToolsScreen(), repo);
      expect(find.text('Become a mentor'), findsOneWidget);
      await t.tap(find.text('Apply to mentor'));
      await t.pumpAndSettle();
      expect(visited, contains(Routes.mentorApply));
    });

    testWidgets('a mentor sees their tools and status', (t) async {
      final repo = FakeMentorshipRepository(mine: myMentor());
      await openAt(t, const MentorToolsScreen(), repo);
      expect(find.text('Live'), findsOneWidget);
      expect(find.text('Availability'), findsOneWidget);
      expect(find.text('Session types'), findsOneWidget);
      expect(find.text('Booking requests'), findsOneWidget);
    });

    testWidgets(
      'booking requests show a real empty state until bookings exist',
      (t) async {
        final repo = FakeMentorshipRepository(mine: myMentor());
        await openAt(t, const MentorRequestsScreen(), repo);
        expect(find.text('No booking requests yet'), findsOneWidget);
      },
    );

    testWidgets('availability saves the toggled day with its range', (t) async {
      final repo = FakeMentorshipRepository(mine: myMentor());
      await openAt(t, const MentorAvailabilityScreen(), repo);
      await t.tap(find.byType(AtToggle).first); // Monday on
      await t.pumpAndSettle();
      await t.tap(find.text('Save availability'));
      await t.pumpAndSettle();
      expect(repo.weeklyCalls, hasLength(1));
      final r = repo.weeklyCalls.single.single;
      expect(r.weekday, 1);
      expect(r.startMinute, 9 * 60);
      expect(r.endMinute, 17 * 60);
      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('session types lists the mentor sessions with prices', (
      t,
    ) async {
      final repo = FakeMentorshipRepository(mine: myMentor());
      await openAt(t, const MentorSessionTypesScreen(), repo);
      expect(find.text('Portfolio review'), findsOneWidget);
      expect(find.text('KES 1,500'), findsOneWidget);
    });
  });

  group('Apply', () {
    testWidgets('the form is prefilled from the Passport', (t) async {
      final repo = FakeMentorshipRepository();
      await openAt(t, const MentorApplyScreen(), repo);
      expect(find.text('Apply to mentor'), findsWidgets);
      expect(find.text('Documentary editor'), findsOneWidget);
      expect(find.text('Editing'), findsOneWidget);
    });

    testWidgets('a pending application shows its status, not the form', (
      t,
    ) async {
      final repo = FakeMentorshipRepository(
        application: MyApplicationDto(
          latest: MentorApplicationDto(
            id: 'a-1',
            status: MentorApplicationStatus.pending,
            headline: 'x',
            yearsExperience: 1,
            statement: 'y',
            expertiseTags: const [],
            disciplineIds: const [],
            credentials: const [],
            proposedSessionTypes: const [],
            evidenceLinks: const [],
            timeZone: 'Africa/Nairobi',
            createdAt: DateTime.utc(2026, 11, 1),
          ),
          canApply: false,
          cannotApplyReason: 'Your application is being reviewed.',
        ),
      );
      await openAt(t, const MentorApplyScreen(), repo);
      expect(find.text('Your application is being reviewed'), findsOneWidget);
      expect(find.text('Withdraw application'), findsOneWidget);
      expect(find.text('Submit application'), findsNothing);
    });
  });
}
