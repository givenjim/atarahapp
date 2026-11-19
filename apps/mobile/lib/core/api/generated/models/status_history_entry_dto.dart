// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'status_history_entry_dto.g.dart';

@JsonSerializable()
class StatusHistoryEntryDto {
  const StatusHistoryEntryDto({
    required this.action,
    required this.at,
    this.actorName,
    this.reason,
    this.from,
    this.to,
  });
  
  factory StatusHistoryEntryDto.fromJson(Map<String, Object?> json) => _$StatusHistoryEntryDtoFromJson(json);
  
  final String action;
  final DateTime at;
  final String? actorName;
  final String? reason;
  final String? from;
  final String? to;

  Map<String, Object?> toJson() => _$StatusHistoryEntryDtoToJson(this);
}
