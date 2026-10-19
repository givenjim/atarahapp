// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_me_achievements_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1MeAchievementsIdResponse _$PatchApiV1MeAchievementsIdResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1MeAchievementsIdResponse(
  data: AchievementDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1MeAchievementsIdResponseToJson(
  PatchApiV1MeAchievementsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
