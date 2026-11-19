// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_refund_dto_mode.dart';
import 'admin_refund_dto_status.dart';

part 'admin_refund_dto.g.dart';

@JsonSerializable()
class AdminRefundDto {
  const AdminRefundDto({
    required this.id,
    required this.amountMinor,
    required this.reason,
    required this.status,
    required this.mode,
    required this.providerReference,
    required this.failureReason,
    required this.requestedById,
    required this.createdAt,
    required this.completedAt,
  });
  
  factory AdminRefundDto.fromJson(Map<String, Object?> json) => _$AdminRefundDtoFromJson(json);
  
  final String id;
  final num amountMinor;
  final String reason;
  final AdminRefundDtoStatus status;
  final AdminRefundDtoMode mode;
  final String? providerReference;
  final String? failureReason;
  final String? requestedById;
  final DateTime createdAt;
  final DateTime? completedAt;

  Map<String, Object?> toJson() => _$AdminRefundDtoToJson(this);
}
