// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_mentor_session_types_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeMentorSessionTypesResponse
_$PostApiV1MeMentorSessionTypesResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1MeMentorSessionTypesResponse(
      data: SessionTypeDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1MeMentorSessionTypesResponseToJson(
  PostApiV1MeMentorSessionTypesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
