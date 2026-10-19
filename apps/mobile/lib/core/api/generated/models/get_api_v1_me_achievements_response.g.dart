// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_achievements_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeAchievementsResponse _$GetApiV1MeAchievementsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeAchievementsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => AchievementDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeAchievementsResponseToJson(
  GetApiV1MeAchievementsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
