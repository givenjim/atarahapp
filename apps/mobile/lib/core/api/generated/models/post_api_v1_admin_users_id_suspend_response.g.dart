// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_users_id_suspend_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminUsersIdSuspendResponse
_$PostApiV1AdminUsersIdSuspendResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminUsersIdSuspendResponse(
      data: AdminUserDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminUsersIdSuspendResponseToJson(
  PostApiV1AdminUsersIdSuspendResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
