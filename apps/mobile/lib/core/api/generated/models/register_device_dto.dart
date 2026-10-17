// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'register_device_dto_platform.dart';

part 'register_device_dto.g.dart';

@JsonSerializable()
class RegisterDeviceDto {
  const RegisterDeviceDto({
    required this.token,
    required this.platform,
    this.appVersion,
  });

  factory RegisterDeviceDto.fromJson(Map<String, Object?> json) =>
      _$RegisterDeviceDtoFromJson(json);

  /// FCM registration token.
  final String token;
  final RegisterDeviceDtoPlatform platform;
  final String? appVersion;

  Map<String, Object?> toJson() => _$RegisterDeviceDtoToJson(this);
}
