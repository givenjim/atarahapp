// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_me_services_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1MeServicesIdResponse _$PatchApiV1MeServicesIdResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1MeServicesIdResponse(
  data: ServiceDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1MeServicesIdResponseToJson(
  PatchApiV1MeServicesIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
