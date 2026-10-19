// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_projects_id_publish_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeProjectsIdPublishResponse
_$PostApiV1MeProjectsIdPublishResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1MeProjectsIdPublishResponse(
      data: ProjectDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1MeProjectsIdPublishResponseToJson(
  PostApiV1MeProjectsIdPublishResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
