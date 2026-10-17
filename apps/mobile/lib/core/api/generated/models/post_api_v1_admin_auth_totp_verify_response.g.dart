// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_auth_totp_verify_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminAuthTotpVerifyResponse
_$PostApiV1AdminAuthTotpVerifyResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminAuthTotpVerifyResponse(
      data: AdminAuthSessionDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminAuthTotpVerifyResponseToJson(
  PostApiV1AdminAuthTotpVerifyResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
