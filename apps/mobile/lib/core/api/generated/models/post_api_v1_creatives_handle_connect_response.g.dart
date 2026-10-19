// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_creatives_handle_connect_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1CreativesHandleConnectResponse
_$PostApiV1CreativesHandleConnectResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1CreativesHandleConnectResponse(
      data: ConnectionStateDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1CreativesHandleConnectResponseToJson(
  PostApiV1CreativesHandleConnectResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
