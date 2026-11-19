// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_mentor_application_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeMentorApplicationResponse
_$PostApiV1MeMentorApplicationResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1MeMentorApplicationResponse(
      data: MentorApplicationDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1MeMentorApplicationResponseToJson(
  PostApiV1MeMentorApplicationResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
