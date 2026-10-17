// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_auth_refresh_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminAuthRefreshResponse _$PostApiV1AdminAuthRefreshResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminAuthRefreshResponse(
  data: AuthSessionDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminAuthRefreshResponseToJson(
  PostApiV1AdminAuthRefreshResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
