// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'booking_request_dto.dart';

part 'get_api_v1_me_mentor_booking_requests_response.g.dart';

@JsonSerializable()
class GetApiV1MeMentorBookingRequestsResponse {
  const GetApiV1MeMentorBookingRequestsResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1MeMentorBookingRequestsResponse.fromJson(Map<String, Object?> json) => _$GetApiV1MeMentorBookingRequestsResponseFromJson(json);
  
  final List<BookingRequestDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeMentorBookingRequestsResponseToJson(this);
}
