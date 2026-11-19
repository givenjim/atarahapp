// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_api_v1_me_mentor_paused_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutApiV1MeMentorPausedResponse _$PutApiV1MeMentorPausedResponseFromJson(
  Map<String, dynamic> json,
) => PutApiV1MeMentorPausedResponse(
  data: MyMentorDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PutApiV1MeMentorPausedResponseToJson(
  PutApiV1MeMentorPausedResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
