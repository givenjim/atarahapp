// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_moderation_cases_id_assign_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminModerationCasesIdAssignResponse
_$PostApiV1AdminModerationCasesIdAssignResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminModerationCasesIdAssignResponse(
  data: AdminCaseDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminModerationCasesIdAssignResponseToJson(
  PostApiV1AdminModerationCasesIdAssignResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
