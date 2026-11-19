// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_mentors_id_resume_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminMentorsIdResumeResponse
_$PostApiV1AdminMentorsIdResumeResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminMentorsIdResumeResponse(
      data: AdminMentorDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminMentorsIdResumeResponseToJson(
  PostApiV1AdminMentorsIdResumeResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
