// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_projects_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeProjectsResponse _$GetApiV1MeProjectsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeProjectsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => ProjectCardDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeProjectsResponseToJson(
  GetApiV1MeProjectsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
