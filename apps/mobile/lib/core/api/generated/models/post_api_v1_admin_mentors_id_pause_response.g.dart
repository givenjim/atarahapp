// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_mentors_id_pause_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminMentorsIdPauseResponse
_$PostApiV1AdminMentorsIdPauseResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminMentorsIdPauseResponse(
      data: AdminMentorDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminMentorsIdPauseResponseToJson(
  PostApiV1AdminMentorsIdPauseResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
