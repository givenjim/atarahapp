// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_mentors_id_remove_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminMentorsIdRemoveResponse
_$PostApiV1AdminMentorsIdRemoveResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminMentorsIdRemoveResponse(
      data: AdminMentorDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminMentorsIdRemoveResponseToJson(
  PostApiV1AdminMentorsIdRemoveResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
