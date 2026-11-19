// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_application_dto.dart';

part 'post_api_v1_admin_mentor_applications_id_approve_response.g.dart';

@JsonSerializable()
class PostApiV1AdminMentorApplicationsIdApproveResponse {
  const PostApiV1AdminMentorApplicationsIdApproveResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1AdminMentorApplicationsIdApproveResponse.fromJson(Map<String, Object?> json) => _$PostApiV1AdminMentorApplicationsIdApproveResponseFromJson(json);
  
  final AdminApplicationDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1AdminMentorApplicationsIdApproveResponseToJson(this);
}
