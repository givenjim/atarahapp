// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_achievements_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeAchievementsResponse _$PostApiV1MeAchievementsResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MeAchievementsResponse(
  data: AchievementDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MeAchievementsResponseToJson(
  PostApiV1MeAchievementsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
