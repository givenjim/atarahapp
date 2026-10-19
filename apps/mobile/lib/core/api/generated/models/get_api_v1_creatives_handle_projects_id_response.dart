// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'project_dto.dart';

part 'get_api_v1_creatives_handle_projects_id_response.g.dart';

@JsonSerializable()
class GetApiV1CreativesHandleProjectsIdResponse {
  const GetApiV1CreativesHandleProjectsIdResponse({
    required this.data,
    this.meta,
  });

  factory GetApiV1CreativesHandleProjectsIdResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1CreativesHandleProjectsIdResponseFromJson(json);

  final ProjectDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1CreativesHandleProjectsIdResponseToJson(this);
}
