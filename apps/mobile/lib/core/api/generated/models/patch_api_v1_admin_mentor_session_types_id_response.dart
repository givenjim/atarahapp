// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_session_type_dto.dart';

part 'patch_api_v1_admin_mentor_session_types_id_response.g.dart';

@JsonSerializable()
class PatchApiV1AdminMentorSessionTypesIdResponse {
  const PatchApiV1AdminMentorSessionTypesIdResponse({
    required this.data,
    this.meta,
  });
  
  factory PatchApiV1AdminMentorSessionTypesIdResponse.fromJson(Map<String, Object?> json) => _$PatchApiV1AdminMentorSessionTypesIdResponseFromJson(json);
  
  final AdminSessionTypeDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PatchApiV1AdminMentorSessionTypesIdResponseToJson(this);
}
