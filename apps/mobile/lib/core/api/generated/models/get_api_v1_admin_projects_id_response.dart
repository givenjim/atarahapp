// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_project_detail_dto.dart';

part 'get_api_v1_admin_projects_id_response.g.dart';

@JsonSerializable()
class GetApiV1AdminProjectsIdResponse {
  const GetApiV1AdminProjectsIdResponse({required this.data, this.meta});

  factory GetApiV1AdminProjectsIdResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1AdminProjectsIdResponseFromJson(json);

  final AdminProjectDetailDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1AdminProjectsIdResponseToJson(this);
}
