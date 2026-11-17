import 'dart:typed_data';

import 'package:atarah/core/analytics/analytics.dart';
import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/l10n/app_localizations.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/core/providers.dart';
import 'package:atarah/features/community/people/people_providers.dart';
import 'package:atarah/features/community/people/people_repository.dart';
import 'package:atarah/features/community/people/people_screens.dart';
import 'package:atarah/features/community/people/people_tab.dart';
import 'package:atarah/features/discover/discover_repository.dart' show PageOf;
import 'package:atarah/features/onboarding/onboarding_providers.dart';
import 'package:atarah/features/profile/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'fake_discover.dart';
import 'fake_onboarding.dart';
import 'fake_profile.dart';

PersonToMeetDto personToMeet({
  String handle = 'wanjiku',
  String name = 'Wanjiku Njeri',
  String? reason = 'Also works in Animation',
  bool pending = false,
  bool verified = false,
  bool open = false,
}) => PersonToMeetDto(
  person: creativeCard(
    handle: handle,
    name: name,
    reason: reason,
    verified: verified,
    open: open,
  ),
  connectionState: pending
      ? PersonConnectionState.pendingSent
      : PersonConnectionState.none,
  connectionId: pending ? 'c-$handle' : null,
);

ConnectionListItemDto connectionItem({
  String id = 'c-1',
  String handle = 'otieno',
  String name = 'Otieno Ouma',
  ConnectionListItemDtoState state = ConnectionListItemDtoState.connected,
}) => ConnectionListItemDto(
  id: id,
  state: state,
  person: ConnectionPersonDto(
    handle: handle,
    displayName: name,
    avatarUrl: null,
    headline: 'Photographer',
    discipline: 'Photography',
  ),
  since: DateTime.utc(2026, 10, 12),
);

BlockedMemberDto blockedMember({
  String userId = 'u-1',
  String name = 'Kamau Mwangi',
}) => BlockedMemberDto(
  userId: userId,
  handle: 'kamau',
  displayName: name,
  avatarUrl: null,
  blockedAt: DateTime.utc(2026, 10, 14),
);

/// In-memory stand-in for the people endpoints. Pages are cut from the lists by `page` and `limit`.
class FakePeopleRepository implements PeopleRepository {
  FakePeopleRepository({
    this.people = const [],
    this.connected = const [],
    this.received = const [],
    this.sent = const [],
    this.blocked = const [],
  });

  List<PersonToMeetDto> people;
  List<ConnectionListItemDto> connected;
  List<ConnectionListItemDto> received;
  List<ConnectionListItemDto> sent;
  List<BlockedMemberDto> blocked;

  AppFailure? suggestionsFailure;
  AppFailure? unblockFailure;

  /// Filters of each suggestions request, in order.
  final List<PeopleFilters> filterCalls = [];
  final List<int> pageCalls = [];
  final List<String> unblocked = [];

  PageOf<T> _page<T>(List<T> all, int page, int limit) =>
      PageOf(all.skip((page - 1) * limit).take(limit).toList(), all.length);

  @override
  Future<PageOf<PersonToMeetDto>> suggestions(
    PeopleFilters f, {
    int page = 1,
    int limit = 20,
  }) async {
    filterCalls.add(f);
    pageCalls.add(page);
    final failure = suggestionsFailure;
    if (failure != null) throw failure;
    return _page(people, page, limit);
  }

  @override
  Future<PageOf<ConnectionListItemDto>> connections(
    ListState listState, {
    int page = 1,
    int limit = 20,
  }) async => _page(
    switch (listState) {
      ListState.pendingReceived => received,
      ListState.pendingSent => sent,
      _ => connected,
    },
    page,
    limit,
  );

  @override
  Future<PageOf<BlockedMemberDto>> blocks({
    int page = 1,
    int limit = 20,
  }) async => _page(blocked, page, limit);

  @override
  Future<void> unblock(String userId) async {
    final f = unblockFailure;
    if (f != null) throw f;
    unblocked.add(userId);
  }
}

/// A 1x1 transparent PNG, so avatar images decode in tests without a network.
final _pixel = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xFF, 0xFF, 0x3F,
  0x00, 0x05, 0xFE, 0x02, 0xFE, 0xA7, 0x35, 0x81, 0x84, 0x00, 0x00, 0x00,
  0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

/// The People area on its own: the tab at `/`, with stand-in routes for what it opens. The real
/// [ConnectionsScreen] and [BlockedScreen] are mounted, so their behaviour is the real one.
class PeopleHarness {
  PeopleHarness({
    FakePeopleRepository? people,
    FakeProfileRepository? profile,
    this.appearance = AtAppearance.light,
    this.start = '/',
  }) : people = people ?? FakePeopleRepository(),
       profile = profile ?? FakeProfileRepository(),
       analytics = RecordingAnalytics();

  final FakePeopleRepository people;
  final FakeProfileRepository profile;
  final AtAppearance appearance;
  final String start;
  final RecordingAnalytics analytics;
  late final GoRouter router;

  String get path => router.state.uri.toString();

  Future<void> pump(WidgetTester t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    router = GoRouter(
      initialLocation: start,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: SafeArea(child: PeopleTab())),
        ),
        GoRoute(
          path: '/creatives',
          builder: (_, _) => const PeopleToMeetScreen(),
        ),
        GoRoute(
          path: '/connections',
          builder: (_, state) => ConnectionsScreen(
            initial: ConnectionsView.parse(state.uri.queryParameters['list']),
          ),
        ),
        GoRoute(path: '/blocked', builder: (_, _) => const BlockedScreen()),
        GoRoute(
          path: '/creatives/:handle',
          builder: (_, state) =>
              Scaffold(body: Text('profile ${state.pathParameters['handle']}')),
        ),
        GoRoute(
          path: '/soon/:phase',
          builder: (_, state) => Scaffold(
            body: Text(
              'soon ${state.pathParameters['phase']} ${state.uri.queryParameters['name']}',
            ),
          ),
        ),
        GoRoute(
          path: '/community',
          builder: (_, _) => const Scaffold(body: Text('community')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await t.pumpWidget(
      ProviderScope(
        retry: noAutomaticRetry,
        overrides: [
          peopleRepositoryProvider.overrideWithValue(people),
          profileRepositoryProvider.overrideWithValue(profile),
          onboardingRepositoryProvider.overrideWithValue(
            FakeOnboardingRepository(),
          ),
          avatarImageProvider.overrideWithValue((_) => MemoryImage(_pixel)),
          analyticsProvider.overrideWithValue(analytics),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AtTheme.light,
          darkTheme: AtTheme.dark,
          themeMode: appearance == AtAppearance.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await t.pumpAndSettle();
  }
}
