// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_payment_event_dto_from_status.dart';
import 'admin_payment_event_dto_kind.dart';
import 'admin_payment_event_dto_source.dart';
import 'admin_payment_event_dto_to_status.dart';

part 'admin_payment_event_dto.g.dart';

@JsonSerializable()
class AdminPaymentEventDto {
  const AdminPaymentEventDto({
    required this.id,
    required this.kind,
    required this.source,
    required this.fromStatus,
    required this.toStatus,
    required this.summary,
    required this.actorId,
    required this.createdAt,
  });
  
  factory AdminPaymentEventDto.fromJson(Map<String, Object?> json) => _$AdminPaymentEventDtoFromJson(json);
  
  final String id;
  final AdminPaymentEventDtoKind kind;
  final AdminPaymentEventDtoSource source;
  final AdminPaymentEventDtoFromStatus? fromStatus;
  final AdminPaymentEventDtoToStatus? toStatus;
  final String summary;
  final String? actorId;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$AdminPaymentEventDtoToJson(this);
}
