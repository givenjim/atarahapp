// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_creatives_handle_skills_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1CreativesHandleSkillsResponse
_$GetApiV1CreativesHandleSkillsResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1CreativesHandleSkillsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => SkillEntryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1CreativesHandleSkillsResponseToJson(
  GetApiV1CreativesHandleSkillsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
