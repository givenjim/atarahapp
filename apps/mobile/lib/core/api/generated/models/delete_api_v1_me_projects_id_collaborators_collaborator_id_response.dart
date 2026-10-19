// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'project_dto.dart';

part 'delete_api_v1_me_projects_id_collaborators_collaborator_id_response.g.dart';

@JsonSerializable()
class DeleteApiV1MeProjectsIdCollaboratorsCollaboratorIdResponse {
  const DeleteApiV1MeProjectsIdCollaboratorsCollaboratorIdResponse({
    required this.data,
    this.meta,
  });

  factory DeleteApiV1MeProjectsIdCollaboratorsCollaboratorIdResponse.fromJson(
    Map<String, Object?> json,
  ) => _$DeleteApiV1MeProjectsIdCollaboratorsCollaboratorIdResponseFromJson(
    json,
  );

  final ProjectDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$DeleteApiV1MeProjectsIdCollaboratorsCollaboratorIdResponseToJson(this);
}
