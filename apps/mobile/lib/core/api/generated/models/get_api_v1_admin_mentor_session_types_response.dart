// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_session_type_dto.dart';

part 'get_api_v1_admin_mentor_session_types_response.g.dart';

@JsonSerializable()
class GetApiV1AdminMentorSessionTypesResponse {
  const GetApiV1AdminMentorSessionTypesResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1AdminMentorSessionTypesResponse.fromJson(Map<String, Object?> json) => _$GetApiV1AdminMentorSessionTypesResponseFromJson(json);
  
  final List<AdminSessionTypeDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminMentorSessionTypesResponseToJson(this);
}
