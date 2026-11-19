// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_mentor_dto.dart';

part 'post_api_v1_admin_mentors_id_resume_response.g.dart';

@JsonSerializable()
class PostApiV1AdminMentorsIdResumeResponse {
  const PostApiV1AdminMentorsIdResumeResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1AdminMentorsIdResumeResponse.fromJson(Map<String, Object?> json) => _$PostApiV1AdminMentorsIdResumeResponseFromJson(json);
  
  final AdminMentorDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1AdminMentorsIdResumeResponseToJson(this);
}
