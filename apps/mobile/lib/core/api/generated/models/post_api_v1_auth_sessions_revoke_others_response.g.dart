// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_auth_sessions_revoke_others_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AuthSessionsRevokeOthersResponse
_$PostApiV1AuthSessionsRevokeOthersResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AuthSessionsRevokeOthersResponse(
  data: SessionsRevokedDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AuthSessionsRevokeOthersResponseToJson(
  PostApiV1AuthSessionsRevokeOthersResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
