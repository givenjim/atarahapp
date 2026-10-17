// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_auth_logout_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AuthLogoutResponse _$PostApiV1AuthLogoutResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AuthLogoutResponse(
  data: LoggedOutDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AuthLogoutResponseToJson(
  PostApiV1AuthLogoutResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
