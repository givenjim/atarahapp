// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'achievement_dto.dart';

part 'get_api_v1_creatives_handle_achievements_response.g.dart';

@JsonSerializable()
class GetApiV1CreativesHandleAchievementsResponse {
  const GetApiV1CreativesHandleAchievementsResponse({
    required this.data,
    this.meta,
  });

  factory GetApiV1CreativesHandleAchievementsResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1CreativesHandleAchievementsResponseFromJson(json);

  final List<AchievementDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1CreativesHandleAchievementsResponseToJson(this);
}
