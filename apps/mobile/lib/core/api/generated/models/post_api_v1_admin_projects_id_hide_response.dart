// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_project_detail_dto.dart';

part 'post_api_v1_admin_projects_id_hide_response.g.dart';

@JsonSerializable()
class PostApiV1AdminProjectsIdHideResponse {
  const PostApiV1AdminProjectsIdHideResponse({required this.data, this.meta});

  factory PostApiV1AdminProjectsIdHideResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminProjectsIdHideResponseFromJson(json);

  final AdminProjectDetailDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminProjectsIdHideResponseToJson(this);
}
