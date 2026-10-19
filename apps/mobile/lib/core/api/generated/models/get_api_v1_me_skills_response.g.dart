// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_skills_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeSkillsResponse _$GetApiV1MeSkillsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeSkillsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => SkillEntryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeSkillsResponseToJson(
  GetApiV1MeSkillsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
