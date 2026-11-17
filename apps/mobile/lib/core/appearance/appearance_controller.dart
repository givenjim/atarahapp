import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/generated/export.dart';
import '../auth/session_controller.dart';
import '../connectivity/connectivity_provider.dart';
import '../design_system/design_system.dart';
import '../providers.dart';
import '../storage/secure_storage.dart';

/// Local persistence of the appearance choice, kept in the same key-value store as other per-install values.
/// Reading never throws: a missing or unreadable value means Light (the default).
class AppearanceStore {
  const AppearanceStore(this._store);

  final KeyValueStore _store;

  static const appearanceKey = 'atarah.appearance';
  static const pendingKey = 'atarah.appearance.pending';

  Future<AtAppearance> load() async {
    try {
      return await _store.read(appearanceKey) == 'DARK'
          ? AtAppearance.dark
          : AtAppearance.light;
    } on Object {
      return AtAppearance.light;
    }
  }

  /// [pending] marks a choice the account has not been told about yet.
  Future<void> save(AtAppearance value, {required bool pending}) async {
    try {
      await _store.write(appearanceKey, value.wire);
      if (pending) {
        await _store.write(pendingKey, '1');
      } else {
        await _store.delete(pendingKey);
      }
    } on Object {
      // Storage unavailable: the choice still applies for this run.
    }
  }

  Future<bool> hasPending() async {
    try {
      return await _store.read(pendingKey) == '1';
    } on Object {
      return false;
    }
  }

  Future<void> clearPending() async {
    try {
      await _store.delete(pendingKey);
    } on Object {
      // Nothing to do.
    }
  }
}

extension AtAppearanceWire on AtAppearance {
  /// The backend value (`LIGHT` | `DARK`).
  String get wire => this == AtAppearance.light ? 'LIGHT' : 'DARK';

  static AtAppearance? fromServer(MeDtoAppearance value) => switch (value) {
    MeDtoAppearance.light => AtAppearance.light,
    MeDtoAppearance.dark => AtAppearance.dark,
    MeDtoAppearance.$unknown => null,
  };
}

/// Sends the appearance to the account.
abstract interface class AppearanceRemote {
  Future<void> save(AtAppearance value);
}

/// `PATCH /api/v1/me/preferences { appearance }` through the generated client.
class ApiAppearanceRemote implements AppearanceRemote {
  const ApiAppearanceRemote(this._client);

  final UsersClient _client;

  @override
  Future<void> save(AtAppearance value) async {
    await _client.updatePreferences(
      body: UpdateAccountPreferencesDto(
        appearance: value == AtAppearance.light
            ? UpdateAccountPreferencesDtoAppearance.light
            : UpdateAccountPreferencesDtoAppearance.dark,
      ),
    );
  }
}

final appearanceStoreProvider = Provider<AppearanceStore>(
  (ref) => AppearanceStore(ref.watch(keyValueStoreProvider)),
);

final appearanceRemoteProvider = Provider<AppearanceRemote>(
  (ref) => ApiAppearanceRemote(UsersClient(ref.watch(apiDioProvider))),
);

/// The choice read from storage in `bootstrap`, before the first frame, so the first frame already has the
/// right theme. Light until overridden.
final initialAppearanceProvider = Provider<AtAppearance>(
  (ref) => AtAppearance.light,
);

/// The member's appearance. Applies instantly and locally; the account follows when it can.
///
/// - Start-up: the stored value (see [initialAppearanceProvider]).
/// - Sign-in or session restore: the account's value wins (a new device adopts it), unless this device has a
///   choice the account has not received yet, in which case that choice is sent instead.
/// - Toggle: stored at once, then `PATCH /me/preferences` without blocking. If that fails (offline), the local
///   value stays and the send is retried on the next sign-in or session restore (app launch) and whenever the
///   device comes back online.
final appearanceControllerProvider =
    NotifierProvider<AppearanceController, AtAppearance>(
      AppearanceController.new,
    );

class AppearanceController extends Notifier<AtAppearance> {
  @override
  AtAppearance build() {
    ref.listen(sessionControllerProvider, (previous, next) {
      final user = next.value;
      if (user != null && previous?.value?.id != user.id) {
        unawaited(_onSignedIn(user));
      }
    }, fireImmediately: true);
    ref.listen(isOnlineProvider, (previous, next) {
      if (previous?.value == false && next.value == true) {
        unawaited(retrySync());
      }
    });
    return ref.read(initialAppearanceProvider);
  }

  AppearanceStore get _store => ref.read(appearanceStoreProvider);

  /// Chooses an appearance: applied and stored now, sent to the account in the background.
  Future<void> set(AtAppearance value) async {
    if (value == state) return;
    state = value;
    await _store.save(value, pending: true);
    unawaited(retrySync());
  }

  Future<void> toggle() => set(state.toggled);

  /// Sends a choice the account has not received yet. Safe to call at any time; a failure keeps it pending.
  Future<void> retrySync() async {
    if (ref.read(sessionControllerProvider).value == null) return;
    final store = _store;
    if (!await store.hasPending() || !ref.mounted) return;
    final sent = state;
    try {
      await ref.read(appearanceRemoteProvider).save(sent);
    } on Object {
      return;
    }
    // A newer toggle made while this request was in flight keeps its own pending mark.
    if (ref.mounted && state == sent) await store.clearPending();
  }

  Future<void> _onSignedIn(MeDto user) async {
    final store = _store;
    final pending = await store.hasPending();
    if (!ref.mounted) return;
    if (pending) {
      await retrySync();
      return;
    }
    final server = AtAppearanceWire.fromServer(user.appearance);
    if (server == null || server == state) return;
    state = server;
    await store.save(server, pending: false);
  }
}
