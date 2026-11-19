// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'booking_gate_dto.g.dart';

@JsonSerializable()
class BookingGateDto {
  const BookingGateDto({
    required this.allowed,
    required this.requiresPro,
    required this.isSelf,
  });
  
  factory BookingGateDto.fromJson(Map<String, Object?> json) => _$BookingGateDtoFromJson(json);
  
  /// The caller may book now (holds MENTORSHIP_BOOKING and is not this mentor).
  final bool allowed;

  /// True when only Atarah Pro is missing: open the premium gate.
  final bool requiresPro;

  /// This is the caller own profile.
  final bool isSelf;

  Map<String, Object?> toJson() => _$BookingGateDtoToJson(this);
}
