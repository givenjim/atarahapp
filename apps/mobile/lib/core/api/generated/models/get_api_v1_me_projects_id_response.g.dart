// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_projects_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeProjectsIdResponse _$GetApiV1MeProjectsIdResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeProjectsIdResponse(
  data: ProjectDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeProjectsIdResponseToJson(
  GetApiV1MeProjectsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
