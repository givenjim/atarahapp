// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_auth_resend_code_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AuthResendCodeResponse _$PostApiV1AuthResendCodeResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AuthResendCodeResponse(
  data: ResendResultDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AuthResendCodeResponseToJson(
  PostApiV1AuthResendCodeResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
