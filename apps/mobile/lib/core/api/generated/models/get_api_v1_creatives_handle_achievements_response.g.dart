// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_creatives_handle_achievements_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1CreativesHandleAchievementsResponse
_$GetApiV1CreativesHandleAchievementsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1CreativesHandleAchievementsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => AchievementDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1CreativesHandleAchievementsResponseToJson(
  GetApiV1CreativesHandleAchievementsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
