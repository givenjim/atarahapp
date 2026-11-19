// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_mentor_application_prefill_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeMentorApplicationPrefillResponse
_$GetApiV1MeMentorApplicationPrefillResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeMentorApplicationPrefillResponse(
  data: ApplicationPrefillDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeMentorApplicationPrefillResponseToJson(
  GetApiV1MeMentorApplicationPrefillResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
