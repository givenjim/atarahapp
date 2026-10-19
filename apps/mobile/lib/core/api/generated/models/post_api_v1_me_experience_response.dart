// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'experience_dto.dart';

part 'post_api_v1_me_experience_response.g.dart';

@JsonSerializable()
class PostApiV1MeExperienceResponse {
  const PostApiV1MeExperienceResponse({required this.data, this.meta});

  factory PostApiV1MeExperienceResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV1MeExperienceResponseFromJson(json);

  final ExperienceDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MeExperienceResponseToJson(this);
}
