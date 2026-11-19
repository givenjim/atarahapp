// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_mentor_booking_requests_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeMentorBookingRequestsResponse
_$GetApiV1MeMentorBookingRequestsResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1MeMentorBookingRequestsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => BookingRequestDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1MeMentorBookingRequestsResponseToJson(
  GetApiV1MeMentorBookingRequestsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
