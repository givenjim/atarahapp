// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'update_achievement_dto_type.dart';

part 'update_achievement_dto.g.dart';

@JsonSerializable()
class UpdateAchievementDto {
  const UpdateAchievementDto({
    this.type,
    this.title,
    this.issuer,
    this.achievedOn,
    this.description,
    this.url,
  });

  factory UpdateAchievementDto.fromJson(Map<String, Object?> json) =>
      _$UpdateAchievementDtoFromJson(json);

  final UpdateAchievementDtoType? type;
  final String? title;

  /// Empty clears it.
  final String? issuer;

  /// Empty clears it.
  final String? achievedOn;

  /// Empty clears it.
  final String? description;

  /// Empty clears it.
  final String? url;

  Map<String, Object?> toJson() => _$UpdateAchievementDtoToJson(this);
}
