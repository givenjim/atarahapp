// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'device_registered_dto.g.dart';

@JsonSerializable()
class DeviceRegisteredDto {
  const DeviceRegisteredDto({
    required this.newDevice,
    required this.verified,
  });
  
  factory DeviceRegisteredDto.fromJson(Map<String, Object?> json) => _$DeviceRegisteredDtoFromJson(json);
  
  /// True the first time this device signs in to the account.
  final bool newDevice;

  /// False when two-step is on and this new device has not passed the second step yet: the app must run the challenge.
  final bool verified;

  Map<String, Object?> toJson() => _$DeviceRegisteredDtoToJson(this);
}
