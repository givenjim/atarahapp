// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_users_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminUsersResponse _$GetApiV1AdminUsersResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminUsersResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => AdminUserDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminUsersResponseToJson(
  GetApiV1AdminUsersResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
