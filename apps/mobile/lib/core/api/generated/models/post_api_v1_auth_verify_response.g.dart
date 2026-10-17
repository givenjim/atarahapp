// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_auth_verify_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AuthVerifyResponse _$PostApiV1AuthVerifyResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AuthVerifyResponse(
  data: AuthSessionDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AuthVerifyResponseToJson(
  PostApiV1AuthVerifyResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
