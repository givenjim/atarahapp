// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_auth_logout_all_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AuthLogoutAllResponse _$PostApiV1AuthLogoutAllResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AuthLogoutAllResponse(
  data: SessionsRevokedDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AuthLogoutAllResponseToJson(
  PostApiV1AuthLogoutAllResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
