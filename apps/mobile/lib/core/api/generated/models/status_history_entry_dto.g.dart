// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_history_entry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatusHistoryEntryDto _$StatusHistoryEntryDtoFromJson(
  Map<String, dynamic> json,
) => StatusHistoryEntryDto(
  action: json['action'] as String,
  at: DateTime.parse(json['at'] as String),
  actorName: json['actorName'] as String?,
  reason: json['reason'] as String?,
  from: json['from'] as String?,
  to: json['to'] as String?,
);

Map<String, dynamic> _$StatusHistoryEntryDtoToJson(
  StatusHistoryEntryDto instance,
) => <String, dynamic>{
  'action': instance.action,
  'at': instance.at.toIso8601String(),
  'actorName': instance.actorName,
  'reason': instance.reason,
  'from': instance.from,
  'to': instance.to,
};
