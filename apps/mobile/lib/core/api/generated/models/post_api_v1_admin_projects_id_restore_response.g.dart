// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_projects_id_restore_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminProjectsIdRestoreResponse
_$PostApiV1AdminProjectsIdRestoreResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminProjectsIdRestoreResponse(
      data: AdminProjectDetailDto.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminProjectsIdRestoreResponseToJson(
  PostApiV1AdminProjectsIdRestoreResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
