// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_projects_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeProjectsResponse _$PostApiV1MeProjectsResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MeProjectsResponse(
  data: ProjectDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MeProjectsResponseToJson(
  PostApiV1MeProjectsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
