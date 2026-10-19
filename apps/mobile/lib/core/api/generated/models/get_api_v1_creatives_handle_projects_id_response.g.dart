// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_creatives_handle_projects_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1CreativesHandleProjectsIdResponse
_$GetApiV1CreativesHandleProjectsIdResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1CreativesHandleProjectsIdResponse(
  data: ProjectDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1CreativesHandleProjectsIdResponseToJson(
  GetApiV1CreativesHandleProjectsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
