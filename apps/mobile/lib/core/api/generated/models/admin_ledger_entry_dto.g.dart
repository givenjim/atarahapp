// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_ledger_entry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminLedgerEntryDto _$AdminLedgerEntryDtoFromJson(Map<String, dynamic> json) =>
    AdminLedgerEntryDto(
      id: json['id'] as String,
      type: AdminLedgerEntryDtoType.fromJson(json['type'] as String),
      grossMinor: json['grossMinor'] as num,
      platformFeeMinor: json['platformFeeMinor'] as num,
      netMinor: json['netMinor'] as num,
      payeeId: json['payeeId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AdminLedgerEntryDtoToJson(
  AdminLedgerEntryDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'grossMinor': instance.grossMinor,
  'platformFeeMinor': instance.platformFeeMinor,
  'netMinor': instance.netMinor,
  'payeeId': instance.payeeId,
  'createdAt': instance.createdAt.toIso8601String(),
};
