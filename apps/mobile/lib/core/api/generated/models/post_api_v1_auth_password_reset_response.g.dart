// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_auth_password_reset_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AuthPasswordResetResponse _$PostApiV1AuthPasswordResetResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AuthPasswordResetResponse(
  data: ResetDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AuthPasswordResetResponseToJson(
  PostApiV1AuthPasswordResetResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
