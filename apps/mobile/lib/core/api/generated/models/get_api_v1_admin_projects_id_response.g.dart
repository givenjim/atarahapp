// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_projects_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminProjectsIdResponse _$GetApiV1AdminProjectsIdResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminProjectsIdResponse(
  data: AdminProjectDetailDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminProjectsIdResponseToJson(
  GetApiV1AdminProjectsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
