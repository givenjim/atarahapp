// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log_entry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuditLogEntryDto _$AuditLogEntryDtoFromJson(Map<String, dynamic> json) =>
    AuditLogEntryDto(
      id: json['id'] as String,
      actorType: AuditLogEntryDtoActorType.fromJson(
        json['actorType'] as String,
      ),
      actorId: json['actorId'] as String?,
      actorName: json['actorName'] as String?,
      action: json['action'] as String,
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String?,
      before: json['before'],
      after: json['after'],
      ip: json['ip'] as String?,
      requestId: json['requestId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AuditLogEntryDtoToJson(AuditLogEntryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'actorType': instance.actorType,
      'actorId': instance.actorId,
      'actorName': instance.actorName,
      'action': instance.action,
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'before': instance.before,
      'after': instance.after,
      'ip': instance.ip,
      'requestId': instance.requestId,
      'createdAt': instance.createdAt.toIso8601String(),
    };
