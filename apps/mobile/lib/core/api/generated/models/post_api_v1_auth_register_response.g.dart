// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_auth_register_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AuthRegisterResponse _$PostApiV1AuthRegisterResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AuthRegisterResponse(
  data: RegisterResultDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AuthRegisterResponseToJson(
  PostApiV1AuthRegisterResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
