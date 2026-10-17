// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_auth_logout_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminAuthLogoutResponse _$PostApiV1AdminAuthLogoutResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminAuthLogoutResponse(
  data: LoggedOutDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminAuthLogoutResponseToJson(
  PostApiV1AdminAuthLogoutResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
