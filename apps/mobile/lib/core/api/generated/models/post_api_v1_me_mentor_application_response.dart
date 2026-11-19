// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'mentor_application_dto.dart';

part 'post_api_v1_me_mentor_application_response.g.dart';

@JsonSerializable()
class PostApiV1MeMentorApplicationResponse {
  const PostApiV1MeMentorApplicationResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1MeMentorApplicationResponse.fromJson(Map<String, Object?> json) => _$PostApiV1MeMentorApplicationResponseFromJson(json);
  
  final MentorApplicationDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MeMentorApplicationResponseToJson(this);
}
