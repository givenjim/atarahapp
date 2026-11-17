// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_moderation_cases_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminModerationCasesIdResponse
_$GetApiV1AdminModerationCasesIdResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1AdminModerationCasesIdResponse(
      data: AdminCaseDetailDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1AdminModerationCasesIdResponseToJson(
  GetApiV1AdminModerationCasesIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
