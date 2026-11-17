import 'dart:async';

import 'package:atarah/core/api/generated/export.dart';
import 'package:atarah/core/appearance/appearance_controller.dart';
import 'package:atarah/core/auth/session_controller.dart';
import 'package:atarah/core/connectivity/connectivity_provider.dart';
import 'package:atarah/core/design_system/design_system.dart';
import 'package:atarah/core/providers.dart';
import 'package:atarah/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_http.dart';
import '../support/fakes.dart';

class _FakeRemote implements AppearanceRemote {
  final List<AtAppearance> saved = [];
  bool failing = false;

  @override
  Future<void> save(AtAppearance value) async {
    if (failing) throw StateError('offline');
    saved.add(value);
  }
}

class _Env {
  _Env({MeDto? user}) : user = user ?? fakeUser();

  final MemoryKeyValueStore store = MemoryKeyValueStore();
  final _FakeRemote remote = _FakeRemote();
  final MeDto user;
  // ignore: close_sinks
  final online = StreamController<bool>.broadcast();

  /// A fresh app launch over the same storage: the start-up value is read exactly as `bootstrap` does.
  Future<ProviderContainer> launch() async {
    final initial = await AppearanceStore(store).load();
    final c = ProviderContainer(
      retry: noAutomaticRetry,
      overrides: [
        keyValueStoreProvider.overrideWithValue(store),
        appearanceRemoteProvider.overrideWithValue(remote),
        initialAppearanceProvider.overrideWithValue(initial),
        authRepositoryProvider.overrideWithValue(
          FakeAuthRepository(restored: user),
        ),
        isOnlineProvider.overrideWith((ref) => online.stream),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }
}

Future<void> tick() async {
  await pumpEventQueue();
  for (var i = 0; i < 12; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

Future<void> settle(ProviderContainer c) async {
  // Like the running app, where AtarahApp watches it: an unwatched provider is paused.
  c.listen(appearanceControllerProvider, (_, _) {});
  await c.read(sessionControllerProvider.future);
  await tick();
}

void main() {
  test('defaults to Light when nothing is stored', () async {
    final c = await _Env().launch();
    expect(c.read(appearanceControllerProvider), AtAppearance.light);
  });

  test('a toggle is stored and kept after a restart', () async {
    final env = _Env();
    var c = await env.launch();
    await settle(c);
    await c.read(appearanceControllerProvider.notifier).set(AtAppearance.dark);
    expect(c.read(appearanceControllerProvider), AtAppearance.dark);
    c.dispose();

    // The restart reads the stored choice before anything else (before the first frame).
    expect(await AppearanceStore(env.store).load(), AtAppearance.dark);
    c = await env.launch();
    expect(c.read(appearanceControllerProvider), AtAppearance.dark);
  });

  test('a toggle is sent to the account', () async {
    final env = _Env();
    final c = await env.launch();
    await settle(c);
    await c.read(appearanceControllerProvider.notifier).set(AtAppearance.dark);
    await tick();
    expect(env.remote.saved, [AtAppearance.dark]);
    expect(await AppearanceStore(env.store).hasPending(), isFalse);
  });

  test('the account value wins after sign-in on a new device', () async {
    final env = _Env(user: fakeUser(appearance: MeDtoAppearance.dark));
    final c = await env.launch();
    expect(c.read(appearanceControllerProvider), AtAppearance.light);
    await settle(c);
    expect(c.read(appearanceControllerProvider), AtAppearance.dark);
    expect(await AppearanceStore(env.store).load(), AtAppearance.dark);
    expect(env.remote.saved, isEmpty);
  });

  test(
    'offline toggle keeps the local value and retries when online',
    () async {
      final env = _Env();
      env.remote.failing = true;
      final c = await env.launch();
      await settle(c);
      await c
          .read(appearanceControllerProvider.notifier)
          .set(AtAppearance.dark);
      await tick();
      expect(c.read(appearanceControllerProvider), AtAppearance.dark);
      expect(await AppearanceStore(env.store).hasPending(), isTrue);

      env.remote.failing = false;
      env.online.add(false);
      await tick();
      env.online.add(true);
      await tick();
      expect(env.remote.saved, [AtAppearance.dark]);
      expect(await AppearanceStore(env.store).hasPending(), isFalse);
    },
  );

  test('an unsent choice survives a restart and beats the stale account '
      'value', () async {
    final env = _Env();
    env.remote.failing = true;
    var c = await env.launch();
    await settle(c);
    await c.read(appearanceControllerProvider.notifier).set(AtAppearance.dark);
    c.dispose();

    env.remote.failing = false;
    c = await env.launch();
    await settle(c);
    expect(c.read(appearanceControllerProvider), AtAppearance.dark);
    expect(env.remote.saved, [AtAppearance.dark]);
    expect(await AppearanceStore(env.store).hasPending(), isFalse);
  });

  test(
    'ApiAppearanceRemote sends appearance through the generated client',
    () async {
      final adapter = FakeAdapter(
        (o) async => json(200, {
          'data': {
            'appearance': 'DARK',
            'locale': 'en',
            'timeZone': 'Africa/Nairobi',
            'marketingOptIn': false,
          },
        }),
      );
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = adapter;
      await ApiAppearanceRemote(UsersClient(dio)).save(AtAppearance.dark);
      expect(adapter.requests.single.method, 'PATCH');
      expect(adapter.requests.single.path, '/api/v1/me/preferences');
      final body = adapter.requests.single.data as Map<String, Object?>;
      expect(body['appearance'], UpdateAccountPreferencesDtoAppearance.dark);
      expect(body['locale'], isNull);
    },
  );
}
