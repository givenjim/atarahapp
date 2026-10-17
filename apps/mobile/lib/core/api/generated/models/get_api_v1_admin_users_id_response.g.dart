// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_users_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminUsersIdResponse _$GetApiV1AdminUsersIdResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminUsersIdResponse(
  data: AdminUserDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminUsersIdResponseToJson(
  GetApiV1AdminUsersIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
