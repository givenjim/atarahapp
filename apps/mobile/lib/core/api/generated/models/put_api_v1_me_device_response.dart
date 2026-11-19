// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'device_registered_dto.dart';

part 'put_api_v1_me_device_response.g.dart';

@JsonSerializable()
class PutApiV1MeDeviceResponse {
  const PutApiV1MeDeviceResponse({
    required this.data,
    this.meta,
  });
  
  factory PutApiV1MeDeviceResponse.fromJson(Map<String, Object?> json) => _$PutApiV1MeDeviceResponseFromJson(json);
  
  final DeviceRegisteredDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PutApiV1MeDeviceResponseToJson(this);
}
