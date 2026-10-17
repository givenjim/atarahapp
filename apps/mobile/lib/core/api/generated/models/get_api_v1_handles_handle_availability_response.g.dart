// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_handles_handle_availability_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1HandlesHandleAvailabilityResponse
_$GetApiV1HandlesHandleAvailabilityResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1HandlesHandleAvailabilityResponse(
  data: HandleAvailabilityDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1HandlesHandleAvailabilityResponseToJson(
  GetApiV1HandlesHandleAvailabilityResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
