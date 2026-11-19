// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_mentor_applications_id_approve_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminMentorApplicationsIdApproveResponse
_$PostApiV1AdminMentorApplicationsIdApproveResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminMentorApplicationsIdApproveResponse(
  data: AdminApplicationDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminMentorApplicationsIdApproveResponseToJson(
  PostApiV1AdminMentorApplicationsIdApproveResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
