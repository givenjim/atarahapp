// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'platform_setting_dto.g.dart';

@JsonSerializable()
class PlatformSettingDto {
  const PlatformSettingDto({
    required this.key,
    required this.value,
    required this.updatedAt,
    this.description,
  });
  
  factory PlatformSettingDto.fromJson(Map<String, Object?> json) => _$PlatformSettingDtoFromJson(json);
  
  final String key;

  /// A string, number or boolean.
  final dynamic value;
  final String? description;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => _$PlatformSettingDtoToJson(this);
}
