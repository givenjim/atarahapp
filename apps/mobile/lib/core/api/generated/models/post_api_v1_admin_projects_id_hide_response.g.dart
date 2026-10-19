// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_projects_id_hide_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminProjectsIdHideResponse
_$PostApiV1AdminProjectsIdHideResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminProjectsIdHideResponse(
      data: AdminProjectDetailDto.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminProjectsIdHideResponseToJson(
  PostApiV1AdminProjectsIdHideResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
