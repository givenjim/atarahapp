import 'dart:async';
import 'dart:io';

import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/auth/session_controller.dart';
import 'package:atarah/core/config/app_config.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/networking/dio_factory.dart' as dio_factory;
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/core/routing/redirect.dart';
import 'package:atarah/core/storage/offline_cache.dart';
import 'package:atarah/core/storage/secure_storage.dart';
import 'package:atarah/features/account/account_repository.dart';
import 'package:atarah/features/profile/profile_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/fake_account.dart';
import '../support/fake_http.dart';
import '../support/fake_opportunities.dart';
import '../support/fake_profile.dart';
import '../support/fakes.dart';

class _MemoryStore implements KeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

void main() {
  group('redirects for the account states', () {
    String? r(
      String location, {
      bool pendingDeletion = false,
      bool twoStepRequired = false,
    }) => computeRedirect(
      status: SessionStatus.signedIn,
      uri: Uri.parse(location),
      devTools: false,
      pendingDeletion: pendingDeletion,
      twoStepRequired: twoStepRequired,
    );

    test('an account scheduled for deletion is offered Restore before anything else', () {
      expect(r('/home', pendingDeletion: true), '/restore');
      expect(r('/opportunities/42', pendingDeletion: true), '/restore');
      expect(r('/restore', pendingDeletion: true), isNull);
    });

    test('a device that owes the second step goes to the challenge', () {
      expect(r('/home', twoStepRequired: true), '/two-step');
      expect(r('/two-step', twoStepRequired: true), isNull);
    });

    test('Restore and the challenge are not reachable by someone who needs neither', () {
      expect(r('/restore'), '/home');
      expect(r('/two-step'), '/home');
      expect(r('/home'), isNull);
    });
  });

  group('a TWO_STEP_REQUIRED answer from the API', () {
    test('is reported once, and other 403s are not mistaken for it', () async {
      var told = 0;
      final adapter = FakeAdapter((o) async {
        if (o.path.endsWith('/two')) {
          return json(
            403,
            errorBody(
              'FORBIDDEN',
              403,
              details: {'reason': 'TWO_STEP_REQUIRED'},
            ),
          );
        }
        return json(
          403,
          errorBody('FORBIDDEN', 403, details: {'reason': 'SOMETHING_ELSE'}),
        );
      });
      final dio = dio_factory.buildApiDio(
        config: const AppConfig(
          flavor: Flavor.dev,
          apiBaseUrl: 'http://test.local',
        ),
        tokens: _NoTokens(),
        onSessionExpired: () {},
        onTwoStepRequired: () => told += 1,
      )..httpClientAdapter = adapter;
      await expectLater(dio.get<Object>('/two'), throwsA(isA<DioException>()));
      expect(told, 1);
      await expectLater(
        dio.get<Object>('/other'),
        throwsA(isA<DioException>()),
      );
      expect(told, 1);
    });
  });

  group('offline', () {
    testWidgets('Apply says it needs a connection and is off', (t) async {
      final h = Harness(
        auth: FakeAuthRepository(restored: fakeUser()),
        opportunities: FakeOpportunitiesRepository(opportunities: [oppDto()]),
        online: false,
      );
      await h.pump(t);
      h.router.go('/opportunities/o-1');
      await t.pumpAndSettle();
      expect(find.byType(AtOfflineBanner), findsOneWidget);
      final apply = find.widgetWithText(AtButton, 'Needs a connection');
      expect(apply, findsOneWidget);
      expect(t.widget<AtButton>(apply).onPressed, isNull);
      expect(find.text('Apply on external website'), findsNothing);
    });

    testWidgets('Apply is on when there is a connection', (t) async {
      final h = Harness(
        auth: FakeAuthRepository(restored: fakeUser()),
        opportunities: FakeOpportunitiesRepository(opportunities: [oppDto()]),
      );
      await h.pump(t);
      h.router.go('/opportunities/o-1');
      await t.pumpAndSettle();
      final apply = find.widgetWithText(AtButton, 'Apply on external website');
      expect(t.widget<AtButton>(apply).onPressed, isNotNull);
    });

    testWidgets('Post is off while offline', (t) async {
      final h = Harness(
        auth: FakeAuthRepository(restored: fakeUser()),
        online: false,
      );
      await h.pump(t);
      h.router.go('/compose');
      await t.pumpAndSettle();
      final post = find.byWidgetPredicate(
        (w) => w is AtButton && w.label == 'Post',
      );
      expect(t.widget<AtButton>(post).onPressed, isNull);
    });
  });

  group('offline cache', () {
    test('is kept per member and never leaks to someone else', () async {
      final store = _MemoryStore();
      final a = OfflineCache(store, 'member-a');
      final b = OfflineCache(store, 'member-b');
      await a.write('passport', {'x': 1});
      expect(await a.read('passport'), {'x': 1});
      expect(await b.read('passport'), isNull);
      // No signed-in member: nothing is read or written.
      final nobody = OfflineCache(store, null);
      await nobody.write('passport', {'x': 2});
      expect(await nobody.read('passport'), isNull);
    });

    test('a broken store never throws', () async {
      final cache = OfflineCache(_BrokenStore(), 'm');
      await cache.write('k', {'a': 1});
      expect(await cache.read('k'), isNull);
    });

    test('the Passport comes from the cache when there is no connection, and only then', () async {
      final store = _MemoryStore();
      var offline = false;
      final adapter = FakeAdapter((o) async {
        if (offline) {
          throw DioException(
            requestOptions: o,
            type: DioExceptionType.connectionError,
          );
        }
        return json(200, {'data': passportDto().toJson()});
      });
      final dio = Dio(BaseOptions(baseUrl: 'http://test.local'))
        ..httpClientAdapter = adapter;
      final repo = ProfileRepository(
        api: AtarahApiClient(dio),
        cache: OfflineCache(store, 'member-a'),
      );
      final online = await repo.passport();
      expect(online.passportNumber, passportDto().passportNumber);

      offline = true;
      expect(
        (await repo.passport()).passportNumber,
        passportDto().passportNumber,
      );

      // Another member on the same device has nothing cached: the failure is shown, not someone else's Passport.
      final other = ProfileRepository(
        api: AtarahApiClient(dio),
        cache: OfflineCache(store, 'member-b'),
      );
      await expectLater(other.passport(), throwsA(isA<NetworkFailure>()));
    });
  });

  group('every Phase 1 screen has its states', () {
    // A source audit: each main screen of every Phase 1 feature must use the shared patterns (a skeleton while it
    // loads, an empty state when there is nothing, an error state with a retry) or be named here with its reason.
    // Behaviour is covered by the widget tests of each feature; this keeps a new screen from skipping them.
    final screens = <String, ({bool loading, bool empty, bool error})>{
      'activity/activity_screen.dart': (
        loading: true,
        empty: false,
        error: true,
      ),
      'activity/applications_screen.dart': (
        loading: true,
        empty: true,
        error: true,
      ),
      'notifications/notifications_screen.dart': (
        loading: true,
        empty: true,
        error: true,
      ),
      'saved/saved_screen.dart': (loading: true, empty: true, error: true),
      'discover/articles_screen.dart': (
        loading: true,
        empty: true,
        error: true,
      ),
      'discover/article_screen.dart': (
        loading: true,
        empty: false,
        error: true,
      ),
      'discover/explore_screen.dart': (
        loading: false,
        empty: true,
        error: true,
      ),
      'discover/search_screen.dart': (loading: true, empty: true, error: true),
      'opportunities/opportunities_screen.dart': (
        loading: true,
        empty: false,
        error: true,
      ),
      'opportunities/opportunities_list_screen.dart': (
        loading: true,
        empty: true,
        error: true,
      ),
      'opportunities/my_opportunities_screen.dart': (
        loading: true,
        empty: true,
        error: true,
      ),
      'opportunities/opportunity_screen.dart': (
        loading: true,
        empty: false,
        error: true,
      ),
      'profile/passport_screen.dart': (
        loading: true,
        empty: false,
        error: true,
      ),
      'profile/creative_profile_screen.dart': (
        loading: true,
        empty: false,
        error: true,
      ),
      'portfolio/skills_screen.dart': (
        loading: false,
        empty: true,
        error: true,
      ),
      'portfolio/experience_screen.dart': (
        loading: false,
        empty: true,
        error: true,
      ),
      'portfolio/achievements_screen.dart': (
        loading: false,
        empty: true,
        error: true,
      ),
      'portfolio/services_screen.dart': (
        loading: false,
        empty: true,
        error: true,
      ),
      'learning/learning_hub_screen.dart': (
        loading: true,
        empty: false,
        error: true,
      ),
      'learning/my_learning_screen.dart': (
        loading: false,
        empty: true,
        error: true,
      ),
      'community/community_screen.dart': (
        loading: false,
        empty: true,
        error: true,
      ),
      'settings/privacy_screens.dart': (
        loading: true,
        empty: false,
        error: true,
      ),
      'settings/security_screen.dart': (
        loading: true,
        empty: false,
        error: true,
      ),
      'settings/help_screens.dart': (loading: true, empty: true, error: true),
      'settings/membership_screen.dart': (
        loading: true,
        empty: false,
        error: true,
      ),
    };

    for (final entry in screens.entries) {
      test(entry.key, () {
        final src = File('lib/features/${entry.key}').readAsStringSync();
        if (entry.value.loading) {
          expect(
            src.contains('AtLoadingBody') || src.contains('AtSkeleton'),
            isTrue,
            reason: 'no skeleton while loading',
          );
        }
        if (entry.value.empty) {
          expect(
            src.contains('AtEmptyState'),
            isTrue,
            reason: 'no empty state',
          );
        }
        if (entry.value.error) {
          expect(
            src.contains('loadFailure') ||
                src.contains('AtErrorState') ||
                src.contains('AtInlineBanner'),
            isTrue,
            reason: 'no error state',
          );
        }
      });
    }

    test('no first-load screen shows a bare spinner any more', () {
      final offenders = <String>[];
      for (final f in Directory('lib/features').listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('_screen.dart')) continue;
        final src = f.readAsStringSync();
        if (RegExp(
          r'loading: \(\) => (const )?Center\(child: CircularProgressIndicator\(\)\)',
        ).hasMatch(src)) {
          offenders.add(f.path);
        }
      }
      expect(offenders, isEmpty);
    });

    test('the shared state patterns exist and are exported', () {
      // AtSkeleton, AtEmptyState (four variants through its icon, title and cta), AtErrorState (three variants),
      // the offline banner and AtPremiumGate are all part of the design system export.
      expect(const AtSkeleton(), isA<Widget>());
      expect(AtErrorVariant.values.length, 3);
      expect(const AtOfflineBanner(), isA<Widget>());
      expect(const AtLoadingBody(), isA<Widget>());
    });
  });

  group('the activity screens show loading, empty and error with fakes', () {
    testWidgets(
      'notifications: a skeleton shows while the first page is pending',
      (t) async {
        final repo = _SlowNotifications();
        final h = Harness(
          auth: FakeAuthRepository(restored: fakeUser()),
          notifications: repo,
        );
        await h.pump(t);
        h.router.go('/notifications');
        await t.pump();
        await t.pump(const Duration(milliseconds: 50));
        expect(find.byType(AtSkeleton), findsWidgets);
        repo.release();
        await t.pumpAndSettle();
        expect(find.byType(AtSkeleton), findsNothing);
      },
    );

    testWidgets(
      'saved, applications and activity each show an error with Try again',
      (t) async {
        final saved = FakeSavedRepository()..failure = const NetworkFailure();
        final activityRepo = FakeActivityRepository()
          ..failure = const NetworkFailure();
        final h = Harness(
          auth: FakeAuthRepository(restored: fakeUser()),
          saved: saved,
          activity: activityRepo,
        );
        await h.pump(t);
        for (final path in ['/saved', '/applications', '/activity']) {
          h.router.go(path);
          await t.pumpAndSettle();
          expect(find.byType(AtErrorState), findsOneWidget, reason: path);
          expect(find.text('Try again'), findsOneWidget, reason: path);
        }
      },
    );
  });
}

class _BrokenStore implements KeyValueStore {
  @override
  Future<String?> read(String key) async => throw StateError('disk');

  @override
  Future<void> write(String key, String value) async =>
      throw StateError('disk');

  @override
  Future<void> delete(String key) async => throw StateError('disk');
}

class _NoTokens implements dio_factory.AccessTokenSource {
  @override
  String? get current => null;

  @override
  Future<String?> refresh() async => null;
}

class _SlowNotifications extends FakeNotificationsRepository {
  final _gate = Completer<void>();

  void release() => _gate.complete();

  @override
  Future<PageOf<NotificationItemDto>> list({
    NotificationCategory? category,
    int page = 1,
    int limit = 20,
  }) async {
    await _gate.future;
    return super.list(category: category, page: page, limit: limit);
  }
}
