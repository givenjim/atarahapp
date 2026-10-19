// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'achievement_dto.dart';

part 'patch_api_v1_me_achievements_id_response.g.dart';

@JsonSerializable()
class PatchApiV1MeAchievementsIdResponse {
  const PatchApiV1MeAchievementsIdResponse({required this.data, this.meta});

  factory PatchApiV1MeAchievementsIdResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PatchApiV1MeAchievementsIdResponseFromJson(json);

  final AchievementDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PatchApiV1MeAchievementsIdResponseToJson(this);
}
