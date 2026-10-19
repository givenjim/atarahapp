// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_experience_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeExperienceResponse _$GetApiV1MeExperienceResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeExperienceResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => ExperienceDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeExperienceResponseToJson(
  GetApiV1MeExperienceResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
