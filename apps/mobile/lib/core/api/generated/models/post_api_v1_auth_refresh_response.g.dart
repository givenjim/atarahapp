// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_auth_refresh_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AuthRefreshResponse _$PostApiV1AuthRefreshResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AuthRefreshResponse(
  data: AuthSessionDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AuthRefreshResponseToJson(
  PostApiV1AuthRefreshResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
