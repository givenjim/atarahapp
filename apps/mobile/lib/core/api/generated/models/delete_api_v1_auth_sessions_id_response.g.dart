// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_api_v1_auth_sessions_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteApiV1AuthSessionsIdResponse _$DeleteApiV1AuthSessionsIdResponseFromJson(
  Map<String, dynamic> json,
) => DeleteApiV1AuthSessionsIdResponse(
  data: RevokedDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$DeleteApiV1AuthSessionsIdResponseToJson(
  DeleteApiV1AuthSessionsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
