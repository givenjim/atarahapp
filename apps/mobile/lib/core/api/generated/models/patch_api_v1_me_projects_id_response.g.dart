// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_me_projects_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1MeProjectsIdResponse _$PatchApiV1MeProjectsIdResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1MeProjectsIdResponse(
  data: ProjectDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1MeProjectsIdResponseToJson(
  PatchApiV1MeProjectsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
