// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'audit_log_entry_dto_actor_type.dart';

part 'audit_log_entry_dto.g.dart';

@JsonSerializable()
class AuditLogEntryDto {
  const AuditLogEntryDto({
    required this.id,
    required this.actorType,
    required this.actorId,
    required this.actorName,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.before,
    required this.after,
    required this.ip,
    required this.requestId,
    required this.createdAt,
  });

  factory AuditLogEntryDto.fromJson(Map<String, Object?> json) =>
      _$AuditLogEntryDtoFromJson(json);

  final String id;
  final AuditLogEntryDtoActorType actorType;
  final String? actorId;

  /// Name of the actor, when known.
  final String? actorName;
  final String action;
  final String entityType;
  final String? entityId;
  final dynamic before;
  final dynamic after;
  final String? ip;
  final String? requestId;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$AuditLogEntryDtoToJson(this);
}
