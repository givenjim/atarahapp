// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_password_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MePasswordResponse _$PostApiV1MePasswordResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MePasswordResponse(
  data: PasswordChangedDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MePasswordResponseToJson(
  PostApiV1MePasswordResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
