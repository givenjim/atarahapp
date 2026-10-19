// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'project_dto.dart';

part 'post_api_v1_me_projects_response.g.dart';

@JsonSerializable()
class PostApiV1MeProjectsResponse {
  const PostApiV1MeProjectsResponse({required this.data, this.meta});

  factory PostApiV1MeProjectsResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV1MeProjectsResponseFromJson(json);

  final ProjectDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MeProjectsResponseToJson(this);
}
