// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_auth_reauth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminAuthReauthResponse _$PostApiV1AdminAuthReauthResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminAuthReauthResponse(
  data: ReauthDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminAuthReauthResponseToJson(
  PostApiV1AdminAuthReauthResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
