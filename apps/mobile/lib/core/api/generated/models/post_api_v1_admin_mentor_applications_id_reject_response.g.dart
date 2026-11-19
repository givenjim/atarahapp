// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_mentor_applications_id_reject_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminMentorApplicationsIdRejectResponse
_$PostApiV1AdminMentorApplicationsIdRejectResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminMentorApplicationsIdRejectResponse(
  data: AdminApplicationDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminMentorApplicationsIdRejectResponseToJson(
  PostApiV1AdminMentorApplicationsIdRejectResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
