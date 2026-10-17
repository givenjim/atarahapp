// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_auth_login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AuthLoginResponse _$PostApiV1AuthLoginResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AuthLoginResponse(
  data: AuthSessionDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AuthLoginResponseToJson(
  PostApiV1AuthLoginResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
