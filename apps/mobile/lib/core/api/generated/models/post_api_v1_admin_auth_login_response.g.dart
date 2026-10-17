// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_auth_login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminAuthLoginResponse _$PostApiV1AdminAuthLoginResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminAuthLoginResponse(
  data: AdminLoginStepDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminAuthLoginResponseToJson(
  PostApiV1AdminAuthLoginResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
