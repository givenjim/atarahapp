// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'achievement_dto_source.dart';
import 'achievement_dto_type.dart';

part 'achievement_dto.g.dart';

@JsonSerializable()
class AchievementDto {
  const AchievementDto({
    required this.id,
    required this.type,
    required this.title,
    required this.source,
    this.issuer,
    this.achievedOn,
    this.description,
    this.url,
  });

  factory AchievementDto.fromJson(Map<String, Object?> json) =>
      _$AchievementDtoFromJson(json);

  final String id;
  final AchievementDtoType type;
  final String title;
  final String? issuer;

  /// A calendar date, YYYY-MM-DD.
  final String? achievedOn;
  final String? description;
  final String? url;
  final AchievementDtoSource source;

  Map<String, Object?> toJson() => _$AchievementDtoToJson(this);
}
