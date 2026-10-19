// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_api_v1_me_projects_id_collaborators_collaborator_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteApiV1MeProjectsIdCollaboratorsCollaboratorIdResponse
_$DeleteApiV1MeProjectsIdCollaboratorsCollaboratorIdResponseFromJson(
  Map<String, dynamic> json,
) => DeleteApiV1MeProjectsIdCollaboratorsCollaboratorIdResponse(
  data: ProjectDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic>
_$DeleteApiV1MeProjectsIdCollaboratorsCollaboratorIdResponseToJson(
  DeleteApiV1MeProjectsIdCollaboratorsCollaboratorIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
