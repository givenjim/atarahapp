// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_auth_totp_setup_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminAuthTotpSetupResponse
_$PostApiV1AdminAuthTotpSetupResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AdminAuthTotpSetupResponse(
      data: TotpSetupDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AdminAuthTotpSetupResponseToJson(
  PostApiV1AdminAuthTotpSetupResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
