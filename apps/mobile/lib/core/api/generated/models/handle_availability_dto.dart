// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'handle_availability_dto_reason.dart';

part 'handle_availability_dto.g.dart';

@JsonSerializable()
class HandleAvailabilityDto {
  const HandleAvailabilityDto({
    required this.handle,
    required this.available,
    required this.reason,
    required this.suggestions,
  });

  factory HandleAvailabilityDto.fromJson(Map<String, Object?> json) =>
      _$HandleAvailabilityDtoFromJson(json);

  final String handle;
  final bool available;
  final HandleAvailabilityDtoReason? reason;

  /// Free alternatives when the handle is taken or reserved.
  final List<String> suggestions;

  Map<String, Object?> toJson() => _$HandleAvailabilityDtoToJson(this);
}
