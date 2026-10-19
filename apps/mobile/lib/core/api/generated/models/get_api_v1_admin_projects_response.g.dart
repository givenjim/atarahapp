// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_projects_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminProjectsResponse _$GetApiV1AdminProjectsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminProjectsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => AdminProjectDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminProjectsResponseToJson(
  GetApiV1AdminProjectsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
