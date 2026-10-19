// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_me_experience_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1MeExperienceIdResponse _$PatchApiV1MeExperienceIdResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1MeExperienceIdResponse(
  data: ExperienceDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1MeExperienceIdResponseToJson(
  PatchApiV1MeExperienceIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
