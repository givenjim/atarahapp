// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_admin_mentor_session_types_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1AdminMentorSessionTypesIdResponse
_$PatchApiV1AdminMentorSessionTypesIdResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1AdminMentorSessionTypesIdResponse(
  data: AdminSessionTypeDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1AdminMentorSessionTypesIdResponseToJson(
  PatchApiV1AdminMentorSessionTypesIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
