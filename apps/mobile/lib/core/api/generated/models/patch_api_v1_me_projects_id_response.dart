// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'project_dto.dart';

part 'patch_api_v1_me_projects_id_response.g.dart';

@JsonSerializable()
class PatchApiV1MeProjectsIdResponse {
  const PatchApiV1MeProjectsIdResponse({required this.data, this.meta});

  factory PatchApiV1MeProjectsIdResponse.fromJson(Map<String, Object?> json) =>
      _$PatchApiV1MeProjectsIdResponseFromJson(json);

  final ProjectDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PatchApiV1MeProjectsIdResponseToJson(this);
}
