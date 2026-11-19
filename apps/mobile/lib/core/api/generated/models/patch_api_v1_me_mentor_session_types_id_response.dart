// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'session_type_dto.dart';

part 'patch_api_v1_me_mentor_session_types_id_response.g.dart';

@JsonSerializable()
class PatchApiV1MeMentorSessionTypesIdResponse {
  const PatchApiV1MeMentorSessionTypesIdResponse({
    required this.data,
    this.meta,
  });
  
  factory PatchApiV1MeMentorSessionTypesIdResponse.fromJson(Map<String, Object?> json) => _$PatchApiV1MeMentorSessionTypesIdResponseFromJson(json);
  
  final SessionTypeDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PatchApiV1MeMentorSessionTypesIdResponseToJson(this);
}
