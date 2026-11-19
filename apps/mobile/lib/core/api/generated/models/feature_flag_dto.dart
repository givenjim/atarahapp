// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'feature_flag_dto.g.dart';

@JsonSerializable()
class FeatureFlagDto {
  const FeatureFlagDto({
    required this.key,
    required this.description,
    required this.enabled,
    required this.phase,
  });
  
  factory FeatureFlagDto.fromJson(Map<String, Object?> json) => _$FeatureFlagDtoFromJson(json);
  
  final String key;
  final String description;
  final bool enabled;

  /// The Master Prompt phase that delivers the capability.
  final num phase;

  Map<String, Object?> toJson() => _$FeatureFlagDtoToJson(this);
}
