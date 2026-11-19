// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_api_v1_me_mentor_availability_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PutApiV1MeMentorAvailabilityResponse
_$PutApiV1MeMentorAvailabilityResponseFromJson(Map<String, dynamic> json) =>
    PutApiV1MeMentorAvailabilityResponse(
      data: AvailabilityDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PutApiV1MeMentorAvailabilityResponseToJson(
  PutApiV1MeMentorAvailabilityResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
