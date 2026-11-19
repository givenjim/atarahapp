// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'register_session_device_dto_platform.dart';

part 'register_session_device_dto.g.dart';

@JsonSerializable()
class RegisterSessionDeviceDto {
  const RegisterSessionDeviceDto({
    required this.deviceHash,
    required this.name,
    required this.platform,
  });
  
  factory RegisterSessionDeviceDto.fromJson(Map<String, Object?> json) => _$RegisterSessionDeviceDtoFromJson(json);
  
  /// Random id the app generates once per install. Never a hardware identifier.
  final String deviceHash;

  /// Shown in Active sessions, e.g. "Pixel 6".
  final String name;
  final RegisterSessionDeviceDtoPlatform platform;

  Map<String, Object?> toJson() => _$RegisterSessionDeviceDtoToJson(this);
}
