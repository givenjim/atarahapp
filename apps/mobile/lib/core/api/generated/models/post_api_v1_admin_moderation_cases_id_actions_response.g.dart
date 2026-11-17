// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_moderation_cases_id_actions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminModerationCasesIdActionsResponse
_$PostApiV1AdminModerationCasesIdActionsResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminModerationCasesIdActionsResponse(
  data: AdminCaseDetailDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminModerationCasesIdActionsResponseToJson(
  PostApiV1AdminModerationCasesIdActionsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
