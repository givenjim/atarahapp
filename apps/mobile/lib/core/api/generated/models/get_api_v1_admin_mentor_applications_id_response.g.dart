// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_mentor_applications_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminMentorApplicationsIdResponse
_$GetApiV1AdminMentorApplicationsIdResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminMentorApplicationsIdResponse(
  data: AdminApplicationDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminMentorApplicationsIdResponseToJson(
  GetApiV1AdminMentorApplicationsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
