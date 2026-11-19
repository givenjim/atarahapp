// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_mentor_availability_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeMentorAvailabilityResponse
_$GetApiV1MeMentorAvailabilityResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1MeMentorAvailabilityResponse(
      data: AvailabilityDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1MeMentorAvailabilityResponseToJson(
  GetApiV1MeMentorAvailabilityResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
