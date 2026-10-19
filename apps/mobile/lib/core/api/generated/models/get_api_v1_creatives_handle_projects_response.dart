// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'project_card_dto.dart';

part 'get_api_v1_creatives_handle_projects_response.g.dart';

@JsonSerializable()
class GetApiV1CreativesHandleProjectsResponse {
  const GetApiV1CreativesHandleProjectsResponse({
    required this.data,
    this.meta,
  });

  factory GetApiV1CreativesHandleProjectsResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1CreativesHandleProjectsResponseFromJson(json);

  final List<ProjectCardDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1CreativesHandleProjectsResponseToJson(this);
}
