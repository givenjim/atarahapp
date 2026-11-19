// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_application_dto.dart';

part 'get_api_v1_admin_mentor_applications_id_response.g.dart';

@JsonSerializable()
class GetApiV1AdminMentorApplicationsIdResponse {
  const GetApiV1AdminMentorApplicationsIdResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1AdminMentorApplicationsIdResponse.fromJson(Map<String, Object?> json) => _$GetApiV1AdminMentorApplicationsIdResponseFromJson(json);
  
  final AdminApplicationDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminMentorApplicationsIdResponseToJson(this);
}
