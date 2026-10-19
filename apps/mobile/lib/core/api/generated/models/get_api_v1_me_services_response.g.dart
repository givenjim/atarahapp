// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_services_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeServicesResponse _$GetApiV1MeServicesResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeServicesResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => ServiceDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeServicesResponseToJson(
  GetApiV1MeServicesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
