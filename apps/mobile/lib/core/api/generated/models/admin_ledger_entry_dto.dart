// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_ledger_entry_dto_type.dart';

part 'admin_ledger_entry_dto.g.dart';

@JsonSerializable()
class AdminLedgerEntryDto {
  const AdminLedgerEntryDto({
    required this.id,
    required this.type,
    required this.grossMinor,
    required this.platformFeeMinor,
    required this.netMinor,
    required this.payeeId,
    required this.createdAt,
  });
  
  factory AdminLedgerEntryDto.fromJson(Map<String, Object?> json) => _$AdminLedgerEntryDtoFromJson(json);
  
  final String id;
  final AdminLedgerEntryDtoType type;
  final num grossMinor;
  final num platformFeeMinor;
  final num netMinor;
  final String? payeeId;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$AdminLedgerEntryDtoToJson(this);
}
