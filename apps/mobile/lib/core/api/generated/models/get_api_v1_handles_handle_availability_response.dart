// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'handle_availability_dto.dart';

part 'get_api_v1_handles_handle_availability_response.g.dart';

@JsonSerializable()
class GetApiV1HandlesHandleAvailabilityResponse {
  const GetApiV1HandlesHandleAvailabilityResponse({
    required this.data,
    this.meta,
  });

  factory GetApiV1HandlesHandleAvailabilityResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1HandlesHandleAvailabilityResponseFromJson(json);

  final HandleAvailabilityDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1HandlesHandleAvailabilityResponseToJson(this);
}
