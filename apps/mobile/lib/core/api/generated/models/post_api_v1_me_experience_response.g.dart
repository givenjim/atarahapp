// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_experience_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeExperienceResponse _$PostApiV1MeExperienceResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MeExperienceResponse(
  data: ExperienceDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MeExperienceResponseToJson(
  PostApiV1MeExperienceResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
