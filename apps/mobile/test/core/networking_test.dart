import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:atarah/core/config/app_config.dart';
import 'package:atarah/core/networking/dio_factory.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/core/networking/session_refresher.dart';
import 'package:atarah/core/storage/token_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Scriptable HTTP layer: each request is answered by [handler].
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(int status, Object body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

Map<String, Object?> errorBody(
  String code,
  int status, {
  Map<String, Object?> details = const {},
}) => {
  'error': {
    'code': code,
    'message': 'msg $code',
    'details': details,
    'requestId': 'rid-1',
  },
};

const config = AppConfig(flavor: Flavor.dev, apiBaseUrl: 'http://test.local');

void main() {
  group('mapError', () {
    test('turns the Atarah error envelope into an ApiFailure with details', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/x'),
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 400,
          data: {
            'error': {
              'code': 'VALIDATION_ERROR',
              'message': 'Some of the information you sent is not valid.',
              'details': {
                'fields': [
                  {
                    'field': 'password',
                    'messages': [
                      'Use at least 8 characters, including a number.',
                    ],
                  },
                ],
              },
              'requestId': 'abc',
            },
          },
        ),
        type: DioExceptionType.badResponse,
      );
      final f = mapError(err) as ApiFailure;
      expect(f.code, 'VALIDATION_ERROR');
      expect(f.statusCode, 400);
      expect(f.requestId, 'abc');
      expect(f.fieldError('password'), startsWith('Use at least 8'));
      expect(f.fieldError('email'), isNull);
    });

    test(
      'exposes details.reason for sign-in lockouts and unverified accounts',
      () {
        const f = ApiFailure(
          code: 'RATE_LIMITED',
          message: 'm',
          statusCode: 429,
          details: {'reason': 'SIGN_IN_LOCKED', 'retryAfterSeconds': 600},
        );
        expect(f.reason, 'SIGN_IN_LOCKED');
      },
    );

    test('connection problems become NetworkFailure; timeouts say so', () {
      DioException of(DioExceptionType t) => DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: t,
      );
      expect(
        mapError(of(DioExceptionType.connectionError)),
        isA<NetworkFailure>(),
      );
      final timeout =
          mapError(of(DioExceptionType.receiveTimeout)) as NetworkFailure;
      expect(timeout.timedOut, isTrue);
      expect(timeout.message, contains('too long'));
    });

    test('anything else is UnexpectedFailure with a safe message', () {
      final f = mapError(StateError('boom'));
      expect(f, isA<UnexpectedFailure>());
      expect(f.message, isNot(contains('boom')));
    });
  });

  group('SessionRefresher (single flight)', () {
    test('many simultaneous 401s trigger exactly one refresh call', () async {
      final store = MemoryTokenStore(
        const StoredTokens(accessToken: 'old', refreshToken: 'r1'),
      );
      var calls = 0;
      final gate = Completer<void>();
      final refresher = SessionRefresher(
        store: store,
        refreshCall: (rt) async {
          calls++;
          await gate.future;
          return const StoredTokens(accessToken: 'new', refreshToken: 'r2');
        },
      );
      final futures = List.generate(8, (_) => refresher.refresh('old'));
      gate.complete();
      final results = await Future.wait(futures);
      expect(calls, 1);
      expect(results.every((t) => t?.accessToken == 'new'), isTrue);
      expect((await store.read())!.refreshToken, 'r2');
    });

    test(
      'a request that already used the newest token does not refresh again',
      () async {
        final store = MemoryTokenStore(
          const StoredTokens(accessToken: 'new', refreshToken: 'r2'),
        );
        var calls = 0;
        final refresher = SessionRefresher(
          store: store,
          refreshCall: (_) async {
            calls++;
            return const StoredTokens(accessToken: 'x', refreshToken: 'y');
          },
        );
        final t = await refresher.refresh('old'); // sent with a stale token
        expect(calls, 0);
        expect(t!.accessToken, 'new');
      },
    );

    test(
      'a failed refresh yields null and leaves the stored tokens alone',
      () async {
        final store = MemoryTokenStore(
          const StoredTokens(accessToken: 'a', refreshToken: 'r'),
        );
        final refresher = SessionRefresher(
          store: store,
          refreshCall: (_) async => throw StateError('nope'),
        );
        expect(await refresher.refresh('a'), isNull);
        expect((await store.read())!.refreshToken, 'r');
      },
    );

    test('no stored session means nothing to refresh', () async {
      final refresher = SessionRefresher(
        store: MemoryTokenStore(),
        refreshCall: (_) async => throw StateError('should not be called'),
      );
      expect(await refresher.refresh(null), isNull);
    });
  });

  group('API Dio', () {
    late MemoryTokenStore store;
    late int expired;
    late SessionRefresher refresher;
    late FakeAdapter adapter;
    late Dio dio;

    Dio build(
      Future<ResponseBody> Function(RequestOptions o) handler, {
      int refreshFails = 0,
    }) {
      store = MemoryTokenStore(
        const StoredTokens(accessToken: 'tok-old', refreshToken: 'ref-1'),
      );
      expired = 0;
      var failures = refreshFails;
      refresher = SessionRefresher(
        store: store,
        refreshCall: (rt) async {
          if (failures > 0) {
            failures--;
            throw StateError('refresh rejected');
          }
          return const StoredTokens(
            accessToken: 'tok-new',
            refreshToken: 'ref-2',
          );
        },
      );
      adapter = FakeAdapter(handler);
      final d = buildApiDio(
        config: config,
        store: store,
        refresher: refresher,
        onSessionExpired: () => expired++,
        retryDelay: Duration.zero,
      );
      d.httpClientAdapter = adapter;
      return d;
    }

    test(
      'every request carries an X-Request-Id and the bearer token',
      () async {
        dio = build((o) async => json(200, {'data': 1}));
        await dio.get<dynamic>('/api/v1/users/me');
        final h = adapter.requests.single.headers;
        expect(h['Authorization'], 'Bearer tok-old');
        expect(h['X-Request-Id'], matches(RegExp(r'^[0-9a-f]{32}$')));
      },
    );

    test('public auth endpoints never carry a token', () async {
      dio = build((o) async => json(200, {'data': 1}));
      for (final p in [
        '/api/v1/auth/login',
        '/api/v1/auth/register',
        '/api/v1/auth/password/forgot',
        '/api/v1/auth/refresh',
      ]) {
        await dio.post<dynamic>(p, data: {});
      }
      expect(
        adapter.requests.every((r) => !r.headers.containsKey('Authorization')),
        isTrue,
      );
    });

    test('a 401 refreshes once and retries with the new token', () async {
      dio = build((o) async {
        if (o.headers['Authorization'] == 'Bearer tok-old') {
          return json(401, errorBody('AUTHENTICATION_REQUIRED', 401));
        }
        return json(200, {'data': 'ok'});
      });
      final res = await dio.get<Map<String, dynamic>>('/api/v1/users/me');
      expect(res.data!['data'], 'ok');
      expect(adapter.requests.map((r) => r.headers['Authorization']), [
        'Bearer tok-old',
        'Bearer tok-new',
      ]);
      expect(refresher.refreshCount, 1);
      expect(expired, 0);
    });

    test(
      'parallel 401s share one refresh (rotation-safe) and all succeed',
      () async {
        dio = build((o) async {
          if (o.headers['Authorization'] == 'Bearer tok-old') {
            return json(401, errorBody('AUTHENTICATION_REQUIRED', 401));
          }
          return json(200, {'data': o.path});
        });
        final results = await Future.wait([
          for (var i = 0; i < 6; i++)
            dio.get<Map<String, dynamic>>('/api/v1/res/$i'),
        ]);
        expect(results.map((r) => r.data!['data']).toSet().length, 6);
        expect(refresher.refreshCount, 1);
        expect(expired, 0);
      },
    );

    test('if the refresh itself is rejected the session is expired and the failure surfaces', () async {
      dio = build(
        (o) async => json(401, errorBody('AUTHENTICATION_REQUIRED', 401)),
        refreshFails: 1,
      );
      await expectLater(
        dio.get<dynamic>('/api/v1/users/me'),
        throwsA(isA<DioException>()),
      );
      expect(expired, 1);
    });

    test('a replayed refresh token (TOKEN_REUSED) ends the session without trying to refresh', () async {
      dio = build(
        (o) async => json(
          401,
          errorBody(
            'AUTHENTICATION_REQUIRED',
            401,
            details: {'reason': 'TOKEN_REUSED'},
          ),
        ),
      );
      await expectLater(
        dio.get<dynamic>('/api/v1/users/me'),
        throwsA(isA<DioException>()),
      );
      expect(refresher.refreshCount, 0);
      expect(expired, 1);
    });

    test(
      'an admin idle timeout (SESSION_IDLE) also ends the session',
      () async {
        dio = build(
          (o) async => json(
            401,
            errorBody(
              'AUTHENTICATION_REQUIRED',
              401,
              details: {'reason': 'SESSION_IDLE'},
            ),
          ),
        );
        await expectLater(
          dio.get<dynamic>('/api/v1/users/me'),
          throwsA(isA<DioException>()),
        );
        expect(expired, 1);
      },
    );

    test(
      'a retried request is not retried a second time (no refresh loop)',
      () async {
        dio = build(
          (o) async => json(401, errorBody('AUTHENTICATION_REQUIRED', 401)),
        );
        await expectLater(
          dio.get<dynamic>('/api/v1/users/me'),
          throwsA(isA<DioException>()),
        );
        expect(adapter.requests.length, 2);
        expect(refresher.refreshCount, 1);
      },
    );

    test(
      'other errors (403, 400) pass straight through without refreshing',
      () async {
        dio = build((o) async => json(403, errorBody('PREMIUM_REQUIRED', 403)));
        await expectLater(
          dio.get<dynamic>('/api/v1/mentors'),
          throwsA(isA<DioException>()),
        );
        expect(refresher.refreshCount, 0);
        expect(expired, 0);
        expect(adapter.requests.length, 1);
      },
    );

    test(
      'safe GETs are retried on connection errors; writes never are',
      () async {
        var n = 0;
        dio = build((o) async {
          n++;
          if (n < 3) {
            throw DioException(
              requestOptions: o,
              type: DioExceptionType.connectionError,
            );
          }
          return json(200, {'data': 'ok'});
        });
        final res = await dio.get<Map<String, dynamic>>('/api/v1/home');
        expect(res.data!['data'], 'ok');
        expect(adapter.requests.length, 3);

        n = 0;
        adapter.requests.clear();
        await expectLater(
          dio.post<dynamic>('/api/v1/posts', data: {}),
          throwsA(isA<DioException>()),
        );
        expect(adapter.requests.length, 1);
      },
    );

    test('gives up after the retry budget on a persistent outage', () async {
      dio = build(
        (o) async => throw DioException(
          requestOptions: o,
          type: DioExceptionType.connectionError,
        ),
      );
      await expectLater(
        dio.get<dynamic>('/api/v1/home'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.requests.length, 3); // first try + 2 retries
    });
  });
}
