// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'achievement_dto.dart';

part 'get_api_v1_me_achievements_response.g.dart';

@JsonSerializable()
class GetApiV1MeAchievementsResponse {
  const GetApiV1MeAchievementsResponse({required this.data, this.meta});

  factory GetApiV1MeAchievementsResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1MeAchievementsResponseFromJson(json);

  final List<AchievementDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeAchievementsResponseToJson(this);
}
