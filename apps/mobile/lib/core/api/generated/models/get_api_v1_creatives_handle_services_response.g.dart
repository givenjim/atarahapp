// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_creatives_handle_services_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1CreativesHandleServicesResponse
_$GetApiV1CreativesHandleServicesResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1CreativesHandleServicesResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => ServiceDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1CreativesHandleServicesResponseToJson(
  GetApiV1CreativesHandleServicesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
