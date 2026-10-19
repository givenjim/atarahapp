// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_projects_id_collaborators_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeProjectsIdCollaboratorsResponse
_$PostApiV1MeProjectsIdCollaboratorsResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MeProjectsIdCollaboratorsResponse(
  data: ProjectDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MeProjectsIdCollaboratorsResponseToJson(
  PostApiV1MeProjectsIdCollaboratorsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
