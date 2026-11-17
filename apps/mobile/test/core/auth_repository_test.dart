import 'dart:convert';

import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/auth/auth_gateway.dart';
import 'package:atarah/core/auth/auth_repository.dart';
import 'package:atarah/core/device/device_registrar.dart';
import 'package:atarah/core/networking/failures.dart';
import 'package:atarah/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_gateway.dart';
import '../support/fake_http.dart';
import '../support/fakes.dart';

class _FixedInfo implements DeviceInfoSource {
  @override
  Future<DeviceDescription> describe() async =>
      const DeviceDescription(name: 'Test Phone', platform: 'ANDROID');
}

AuthGatewayException gw(String code, {int? status, bool network = false}) =>
    AuthGatewayException(code: code, statusCode: status, network: network);

void main() {
  late FakeAuthGateway gateway;
  late FakeAdapter adapter;
  late AuthRepository repo;
  late MemoryKeyValueStore store;
  late int meStatus;

  AuthRepository build(FakeAdapter a) {
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local'))
      ..httpClientAdapter = a;
    return AuthRepository(
      gateway: gateway,
      api: AtarahApiClient(dio),
      devices: DeviceRegistrar(dio: dio, store: store, info: _FixedInfo()),
      legalVersions: () async => (terms: '2026-10', privacy: '2026-09'),
    );
  }

  setUp(() {
    gateway = FakeAuthGateway();
    store = MemoryKeyValueStore();
    meStatus = 200;
    adapter = FakeAdapter((o) async {
      if (o.path == '/api/v1/users/me') {
        return meStatus == 200
            ? json(200, {'data': jsonDecode(jsonEncode(fakeUser()))})
            : json(meStatus, errorBody('AUTHENTICATION_REQUIRED', meStatus));
      }
      if (o.path == '/api/v1/me/device') {
        return json(200, {
          'data': {'newDevice': true},
        });
      }
      return json(404, errorBody('NOT_FOUND', 404));
    });
    repo = build(adapter);
  });

  Future<ApiFailure> failureOf(Future<Object?> call) async {
    try {
      await call;
    } on ApiFailure catch (f) {
      return f;
    }
    fail('expected an ApiFailure');
  }

  group('restoreSession', () {
    test('no stored session is signed out without a request', () async {
      expect(await repo.restoreSession(), isNull);
      expect(adapter.requests, isEmpty);
    });

    test('a stored session loads the member from the API', () async {
      gateway.session = true;
      final me = await repo.restoreSession();
      expect(me!.fullName, 'Test Member');
    });

    test('a rejected session is cleared', () async {
      gateway.session = true;
      meStatus = 401;
      expect(await repo.restoreSession(), isNull);
      expect(gateway.calls, contains('signOut'));
    });

    test('offline stays a failure, not a sign-out', () async {
      gateway.session = true;
      final offline = build(
        FakeAdapter(
          (o) async => throw DioException(
            requestOptions: o,
            type: DioExceptionType.connectionError,
          ),
        ),
      );
      await expectLater(
        offline.restoreSession(),
        throwsA(isA<NetworkFailure>()),
      );
      expect(gateway.calls, isNot(contains('signOut')));
    });
  });

  group('register', () {
    test('sends the name and the legal versions as user metadata', () async {
      final ticket = await repo.register(
        fullName: '  Nia Wanjiru ',
        identifier: '0712345678',
        password: 'Passw0rd-1',
      );
      expect(gateway.calls, ['signUp:+254712345678']);
      expect(gateway.lastMetadata, {
        'full_name': 'Nia Wanjiru',
        'terms_version': '2026-10',
        'privacy_version': '2026-09',
      });
      expect(
        ticket.resendAvailableAt!.difference(DateTime.now()).inSeconds,
        inInclusiveRange(55, 60),
      );
    });

    test('an existing account is the ACCOUNT_EXISTS conflict', () async {
      gateway.accountExists = true;
      final f = await failureOf(
        repo.register(
          fullName: 'Nia',
          identifier: 'nia@example.com',
          password: 'Passw0rd-1',
        ),
      );
      expect(f.reason, 'ACCOUNT_EXISTS');
      expect(
        f.message,
        'An account with this email already exists. Sign in instead?',
      );
      expect(
        f.fieldError('identifier'),
        'An account with this email already exists.',
      );
    });

    test('a phone number says phone number', () async {
      gateway.failures['signUp'] = gw('phone_exists', status: 422);
      final f = await failureOf(
        repo.register(
          fullName: 'Nia',
          identifier: '0712345678',
          password: 'Passw0rd-1',
        ),
      );
      expect(f.message, contains('phone number'));
    });

    test('a weak password is flagged for the password field', () async {
      gateway.failures['signUp'] = gw('weak_password', status: 422);
      final f = await failureOf(
        repo.register(
          fullName: 'Nia',
          identifier: 'nia@example.com',
          password: '12345678',
        ),
      );
      expect(f.reason, 'WEAK_PASSWORD');
      expect(f.fieldError('password'), isNotNull);
    });

    test('offline is a NetworkFailure', () async {
      gateway.failures['signUp'] = gw('network', network: true);
      await expectLater(
        repo.register(
          fullName: 'Nia',
          identifier: 'nia@example.com',
          password: 'Passw0rd-1',
        ),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('verify', () {
    test('a good code signs in and loads the member', () async {
      final me = await repo.verify(
        identifier: 'nia@example.com',
        code: '123456',
      );
      expect(gateway.calls, ['verifySignup:nia@example.com:123456']);
      expect(me.fullName, 'Test Member');
    });

    test('a wrong or expired code is a code field error', () async {
      gateway.failures['verifySignup'] = gw('otp_expired', status: 403);
      final f = await failureOf(
        repo.verify(identifier: 'nia@example.com', code: '000000'),
      );
      expect(f.message, 'That code is not right or has expired.');
      expect(f.fieldError('code'), 'That code is not right or has expired.');
    });
  });

  group('resend', () {
    test('returns a 60 second cooldown', () async {
      final at = await repo.resendCode('nia@example.com');
      expect(
        at!.difference(DateTime.now()).inSeconds,
        inInclusiveRange(55, 60),
      );
    });

    test('the provider rate limit becomes the cooldown message', () async {
      gateway.failures['resend'] = gw(
        'over_email_send_rate_limit',
        status: 429,
      );
      final f = await failureOf(repo.resendCode('nia@example.com'));
      expect(f.code, 'RATE_LIMITED');
      expect(f.message, 'Please wait a moment before asking for another code.');
    });
  });

  group('signIn', () {
    test('signs in and loads the member', () async {
      final me = await repo.signIn(
        identifier: 'nia@example.com',
        password: 'Passw0rd-1',
      );
      expect(me.email, 'member@test.atarah.local');
    });

    test('a wrong password shows the usual banner', () async {
      gateway.failures['signIn'] = gw('invalid_credentials', status: 400);
      final f = await failureOf(
        repo.signIn(identifier: 'nia@example.com', password: 'x'),
      );
      expect(f.code, 'INVALID_CREDENTIALS');
      expect(f.message, AuthMessages.wrongPassword);
    });

    test(
      'an unverified account gets a fresh code and the code screen',
      () async {
        gateway.failures['signIn'] = gw('email_not_confirmed', status: 400);
        final f = await failureOf(
          repo.signIn(identifier: 'nia@example.com', password: 'Passw0rd-1'),
        );
        expect(f.reason, 'ACCOUNT_NOT_VERIFIED');
        expect(gateway.calls, contains('resend:nia@example.com'));
      },
    );

    test('too many attempts is the lock-out message', () async {
      gateway.failures['signIn'] = gw('over_request_rate_limit', status: 429);
      final f = await failureOf(
        repo.signIn(identifier: 'nia@example.com', password: 'x'),
      );
      expect(f.reason, 'SIGN_IN_LOCKED');
    });

    test('an account the API refuses is signed out again', () async {
      meStatus = 403;
      final f = await failureOf(
        repo.signIn(identifier: 'nia@example.com', password: 'Passw0rd-1'),
      );
      expect(f.statusCode, 403);
      expect(gateway.calls.last, 'signOut');
    });
  });

  group('recovery', () {
    test('asking for a code hides rate limits', () async {
      gateway.failures['sendRecovery'] = gw(
        'over_email_send_rate_limit',
        status: 429,
      );
      await repo.requestPasswordReset('nia@example.com');
    });

    test(
      'reset verifies the code, sets the password, ends other sessions',
      () async {
        final me = await repo.resetPassword(
          identifier: 'nia@example.com',
          code: '123456',
          newPassword: 'Passw0rd-2',
        );
        expect(gateway.calls, [
          'verifyRecovery:nia@example.com:123456',
          'updatePassword',
          'signOutOthers',
        ]);
        expect(me.fullName, 'Test Member');
      },
    );

    test('a wrong recovery code stops before the password changes', () async {
      gateway.failures['verifyRecovery'] = gw('otp_expired', status: 403);
      final f = await failureOf(
        repo.resetPassword(
          identifier: 'nia@example.com',
          code: '000000',
          newPassword: 'Passw0rd-2',
        ),
      );
      expect(f.fieldError('code'), isNotNull);
      expect(gateway.calls, isNot(contains('updatePassword')));
    });

    test('a rejected new password leaves no session behind', () async {
      gateway.failures['updatePassword'] = gw('weak_password', status: 422);
      final f = await failureOf(
        repo.resetPassword(
          identifier: 'nia@example.com',
          code: '123456',
          newPassword: '12345678',
        ),
      );
      expect(f.fieldError('newPassword'), isNotNull);
      expect(gateway.calls.last, 'signOut');
    });

    test('phone recovery uses the normalised phone number', () async {
      await repo.requestPasswordReset('0712345678');
      expect(gateway.calls, ['sendRecovery:+254712345678']);
    });
  });

  group('device registration', () {
    test('sends a random per-install id, a name and the platform', () async {
      await repo.registerDevice();
      final req = adapter.requests.single;
      expect(req.method, 'PUT');
      expect(req.path, '/api/v1/me/device');
      final body = req.data as Map<String, dynamic>;
      expect(body['name'], 'Test Phone');
      expect(body['platform'].toString(), 'ANDROID');
      expect(body['deviceHash'], matches(RegExp(r'^[A-Za-z0-9_-]{16,64}$')));
      expect(await store.read(DeviceRegistrar.storeKey), body['deviceHash']);
    });

    test('the id is made once and reused', () async {
      await repo.registerDevice();
      await repo.registerDevice();
      final ids = adapter.requests
          .map((r) => (r.data as Map<String, dynamic>)['deviceHash'])
          .toSet();
      expect(ids.length, 1);
    });

    test('a failing call never throws', () async {
      final failing = FakeAdapter(
        (o) async => json(500, errorBody('INTERNAL_ERROR', 500)),
      );
      final dio = Dio(BaseOptions(baseUrl: 'http://test.local'))
        ..httpClientAdapter = failing;
      final registrar = DeviceRegistrar(
        dio: dio,
        store: store,
        info: _FixedInfo(),
      );
      expect(await registrar.register(), isNull);
    });
  });

  test('sign out ends the provider session', () async {
    await repo.signOut();
    expect(gateway.calls, ['signOut']);
  });
}
