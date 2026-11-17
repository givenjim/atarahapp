import 'dart:async';

import 'package:atarah/core/config/app_config.dart';
import 'package:atarah/core/networking/dio_factory.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_http.dart';

/// The Supabase session as the interceptor sees it: a current token, and a refresh that can succeed, fail
/// (session over) or throw (offline).
class FakeTokens implements AccessTokenSource {
  FakeTokens({this.current = 'tok-old'});

  @override
  String? current;
  int refreshCount = 0;
  bool sessionOver = false;
  bool offline = false;
  final Completer<void> gate = Completer<void>()..complete();

  @override
  Future<String?> refresh() async {
    refreshCount++;
    await gate.future;
    if (offline) throw StateError('offline');
    if (sessionOver) return null;
    return current = 'tok-new';
  }
}

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
                      'Use at least 8 characters, including a letter and a number.',
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

  group('API Dio', () {
    late int expired;
    late FakeTokens tokens;
    late FakeAdapter adapter;
    late Dio dio;

    Dio build(
      Future<ResponseBody> Function(RequestOptions o) handler, {
      FakeTokens? withTokens,
    }) {
      tokens = withTokens ?? FakeTokens();
      expired = 0;
      adapter = FakeAdapter(handler);
      final d = buildApiDio(
        config: config,
        tokens: tokens,
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

    test('public content endpoints never carry a token', () async {
      dio = build((o) async => json(200, {'data': 1}));
      await dio.get<dynamic>('/api/v1/config/public');
      await dio.get<dynamic>('/api/v1/legal/TERMS');
      expect(
        adapter.requests.every((r) => !r.headers.containsKey('Authorization')),
        isTrue,
      );
    });

    test(
      'a request with no session carries no token and is not refreshed',
      () async {
        dio = build(
          (o) async => json(401, errorBody('AUTHENTICATION_REQUIRED', 401)),
          withTokens: FakeTokens(current: null),
        );
        await expectLater(
          dio.get<dynamic>('/api/v1/users/me'),
          throwsA(isA<DioException>()),
        );
        expect(tokens.refreshCount, 0);
        expect(
          adapter.requests.single.headers.containsKey('Authorization'),
          isFalse,
        );
      },
    );

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
      expect(tokens.refreshCount, 1);
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
        expect(tokens.refreshCount, 1);
        expect(expired, 0);
      },
    );

    test('if the session cannot be refreshed the session is expired and the failure surfaces', () async {
      dio = build(
        (o) async => json(401, errorBody('AUTHENTICATION_REQUIRED', 401)),
        withTokens: FakeTokens()..sessionOver = true,
      );
      await expectLater(
        dio.get<dynamic>('/api/v1/users/me'),
        throwsA(isA<DioException>()),
      );
      expect(expired, 1);
    });

    test(
      'a refresh that fails because the device is offline keeps the session',
      () async {
        dio = build(
          (o) async => json(401, errorBody('AUTHENTICATION_REQUIRED', 401)),
          withTokens: FakeTokens()..offline = true,
        );
        await expectLater(
          dio.get<dynamic>('/api/v1/users/me'),
          throwsA(isA<DioException>()),
        );
        expect(expired, 0);
      },
    );

    test('a request sent with a stale token retries with the newer SDK token, no refresh', () async {
      final t = FakeTokens();
      dio = build((o) async {
        if (o.headers['Authorization'] == 'Bearer tok-old') {
          // Another path (the SDK's own timer) rotated the token while this request was in flight.
          t.current = 'tok-sdk';
          return json(401, errorBody('AUTHENTICATION_REQUIRED', 401));
        }
        return json(200, {'data': 'ok'});
      }, withTokens: t);
      await dio.get<dynamic>('/api/v1/users/me');
      expect(t.refreshCount, 0);
      expect(adapter.requests.last.headers['Authorization'], 'Bearer tok-sdk');
    });

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
        expect(tokens.refreshCount, 1);
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
        expect(tokens.refreshCount, 0);
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
