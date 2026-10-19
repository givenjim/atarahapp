// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_services_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeServicesResponse _$PostApiV1MeServicesResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MeServicesResponse(
  data: ServiceDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MeServicesResponseToJson(
  PostApiV1MeServicesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
