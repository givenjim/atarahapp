// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_auth_google_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AuthGoogleResponse _$PostApiV1AuthGoogleResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AuthGoogleResponse(
  data: AuthSessionDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AuthGoogleResponseToJson(
  PostApiV1AuthGoogleResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
