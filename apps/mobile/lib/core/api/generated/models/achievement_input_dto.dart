// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'achievement_input_dto_type.dart';

part 'achievement_input_dto.g.dart';

@JsonSerializable()
class AchievementInputDto {
  const AchievementInputDto({
    required this.type,
    required this.title,
    this.issuer,
    this.achievedOn,
    this.description,
    this.url,
  });

  factory AchievementInputDto.fromJson(Map<String, Object?> json) =>
      _$AchievementInputDtoFromJson(json);

  final AchievementInputDtoType type;
  final String title;

  /// Who gave it.
  final String? issuer;

  /// A calendar date, YYYY-MM-DD.
  final String? achievedOn;
  final String? description;

  /// An https link to proof or coverage.
  final String? url;

  Map<String, Object?> toJson() => _$AchievementInputDtoToJson(this);
}
