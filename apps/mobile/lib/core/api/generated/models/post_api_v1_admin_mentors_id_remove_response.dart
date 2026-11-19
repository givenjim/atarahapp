// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_mentor_dto.dart';

part 'post_api_v1_admin_mentors_id_remove_response.g.dart';

@JsonSerializable()
class PostApiV1AdminMentorsIdRemoveResponse {
  const PostApiV1AdminMentorsIdRemoveResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1AdminMentorsIdRemoveResponse.fromJson(Map<String, Object?> json) => _$PostApiV1AdminMentorsIdRemoveResponseFromJson(json);
  
  final AdminMentorDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1AdminMentorsIdRemoveResponseToJson(this);
}
