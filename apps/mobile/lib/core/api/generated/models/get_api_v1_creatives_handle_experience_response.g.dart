// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_creatives_handle_experience_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1CreativesHandleExperienceResponse
_$GetApiV1CreativesHandleExperienceResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1CreativesHandleExperienceResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => ExperienceDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1CreativesHandleExperienceResponseToJson(
  GetApiV1CreativesHandleExperienceResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
