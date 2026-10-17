// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_users_id_reactivate_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminUsersIdReactivateResponse
_$PostApiV1AdminUsersIdReactivateResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminUsersIdReactivateResponse(
      data: AdminUserDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminUsersIdReactivateResponseToJson(
  PostApiV1AdminUsersIdReactivateResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
