// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_auth_password_forgot_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AuthPasswordForgotResponse
_$PostApiV1AuthPasswordForgotResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1AuthPasswordForgotResponse(
      data: SentDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1AuthPasswordForgotResponseToJson(
  PostApiV1AuthPasswordForgotResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
