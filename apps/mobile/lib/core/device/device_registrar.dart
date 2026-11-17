import 'dart:convert';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../api/generated/models/register_session_device_dto.dart';
import '../api/generated/models/register_session_device_dto_platform.dart';
import '../api/generated/users/users_client.dart';
import '../storage/secure_storage.dart';

/// What the Active sessions screen shows for this device.
class DeviceDescription {
  const DeviceDescription({required this.name, required this.platform});

  final String name;

  /// `ANDROID`, `IOS` or `WEB` (the API's enum).
  final String platform;
}

abstract interface class DeviceInfoSource {
  Future<DeviceDescription> describe();
}

/// A human device name from `device_info_plus`, with a plain fallback if the platform will not say.
class PlatformDeviceInfoSource implements DeviceInfoSource {
  const PlatformDeviceInfoSource();

  @override
  Future<DeviceDescription> describe() async {
    final plugin = DeviceInfoPlugin();
    try {
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
          final info = await plugin.iosInfo;
          final name = info.name.trim();
          return DeviceDescription(
            name: name.isEmpty ? 'iPhone' : name,
            platform: 'IOS',
          );
        default:
          final info = await plugin.androidInfo;
          final model = '${info.manufacturer} ${info.model}'.trim();
          return DeviceDescription(
            name: model.isEmpty ? 'Android phone' : _cap(model),
            platform: 'ANDROID',
          );
      }
    } on Object {
      return DeviceDescription(
        name: defaultTargetPlatform == TargetPlatform.iOS
            ? 'iPhone'
            : 'Android phone',
        platform: defaultTargetPlatform == TargetPlatform.iOS
            ? 'IOS'
            : 'ANDROID',
      );
    }
  }

  static String _cap(String s) => s.length > 80 ? s.substring(0, 80) : s;
}

/// Tells the API about this install after every sign-in (`PUT /me/device`), so the account can spot a new
/// device and the session list can name it. The id is random, made once per install and kept in the keystore.
/// It is never a hardware identifier. A failure is swallowed: the app works without it.
class DeviceRegistrar {
  DeviceRegistrar({
    required this.dio,
    required this.store,
    this.info = const PlatformDeviceInfoSource(),
    Random? random,
  }) : _random = random ?? Random.secure();

  final Dio dio;
  final KeyValueStore store;
  final DeviceInfoSource info;
  final Random _random;

  static const storeKey = 'atarah.device_id';

  Future<String> deviceId() async {
    final existing = await store.read(storeKey);
    if (existing != null && existing.length >= 16) return existing;
    final bytes = List<int>.generate(24, (_) => _random.nextInt(256));
    final id = base64UrlEncode(bytes).replaceAll('=', '');
    await store.write(storeKey, id);
    return id;
  }

  /// Returns true when the API says this is the first time this device signed in to the account.
  Future<bool?> register() async {
    try {
      final id = await deviceId();
      final d = await info.describe();
      final res = await UsersClient(dio).registerDevice(
        body: RegisterSessionDeviceDto(
          deviceHash: id,
          name: d.name,
          platform: RegisterSessionDeviceDtoPlatform.values.firstWhere(
            (p) => p.json == d.platform,
            orElse: () => RegisterSessionDeviceDtoPlatform.android,
          ),
        ),
      );
      return res.data.newDevice;
    } on Object {
      return null;
    }
  }
}
