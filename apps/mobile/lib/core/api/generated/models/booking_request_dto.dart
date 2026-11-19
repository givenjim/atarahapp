// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'booking_request_dto.g.dart';

@JsonSerializable()
class BookingRequestDto {
  const BookingRequestDto({
    required this.id,
    required this.menteeName,
    required this.sessionName,
    required this.startsAt,
    required this.endsAt,
    required this.status,
  });
  
  factory BookingRequestDto.fromJson(Map<String, Object?> json) => _$BookingRequestDtoFromJson(json);
  
  final String id;
  final String menteeName;
  final String sessionName;
  final DateTime startsAt;
  final DateTime endsAt;
  final String status;

  Map<String, Object?> toJson() => _$BookingRequestDtoToJson(this);
}
