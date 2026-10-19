// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_project_dto.dart';

part 'get_api_v1_admin_projects_response.g.dart';

@JsonSerializable()
class GetApiV1AdminProjectsResponse {
  const GetApiV1AdminProjectsResponse({required this.data, this.meta});

  factory GetApiV1AdminProjectsResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1AdminProjectsResponseFromJson(json);

  final List<AdminProjectDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminProjectsResponseToJson(this);
}
