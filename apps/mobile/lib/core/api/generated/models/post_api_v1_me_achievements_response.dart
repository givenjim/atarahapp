// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'achievement_dto.dart';

part 'post_api_v1_me_achievements_response.g.dart';

@JsonSerializable()
class PostApiV1MeAchievementsResponse {
  const PostApiV1MeAchievementsResponse({required this.data, this.meta});

  factory PostApiV1MeAchievementsResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV1MeAchievementsResponseFromJson(json);

  final AchievementDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1MeAchievementsResponseToJson(this);
}
