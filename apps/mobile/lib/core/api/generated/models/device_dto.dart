// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'device_dto.g.dart';

@JsonSerializable()
class DeviceDto {
  const DeviceDto({required this.id});

  factory DeviceDto.fromJson(Map<String, Object?> json) =>
      _$DeviceDtoFromJson(json);

  final String id;

  Map<String, Object?> toJson() => _$DeviceDtoToJson(this);
}
