// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'availability_dto.dart';

part 'put_api_v1_me_mentor_availability_response.g.dart';

@JsonSerializable()
class PutApiV1MeMentorAvailabilityResponse {
  const PutApiV1MeMentorAvailabilityResponse({
    required this.data,
    this.meta,
  });
  
  factory PutApiV1MeMentorAvailabilityResponse.fromJson(Map<String, Object?> json) => _$PutApiV1MeMentorAvailabilityResponseFromJson(json);
  
  final AvailabilityDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PutApiV1MeMentorAvailabilityResponseToJson(this);
}
