// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'session_type_dto.dart';

part 'post_api_v1_me_mentor_session_types_response.g.dart';

@JsonSerializable()
class PostApiV1MeMentorSessionTypesResponse {
  const PostApiV1MeMentorSessionTypesResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1MeMentorSessionTypesResponse.fromJson(Map<String, Object?> json) => _$PostApiV1MeMentorSessionTypesResponseFromJson(json);
  
  final SessionTypeDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MeMentorSessionTypesResponseToJson(this);
}
