// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_me_mentor_session_types_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1MeMentorSessionTypesIdResponse
_$PatchApiV1MeMentorSessionTypesIdResponseFromJson(Map<String, dynamic> json) =>
    PatchApiV1MeMentorSessionTypesIdResponse(
      data: SessionTypeDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PatchApiV1MeMentorSessionTypesIdResponseToJson(
  PatchApiV1MeMentorSessionTypesIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
