// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attention_queue_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttentionQueueDto _$AttentionQueueDtoFromJson(Map<String, dynamic> json) =>
    AttentionQueueDto(
      key: json['key'] as String,
      label: json['label'] as String,
      count: json['count'] as num,
      priority: AttentionQueueDtoPriority.fromJson(json['priority'] as String),
      path: json['path'] as String,
      oldestAt: json['oldestAt'] == null
          ? null
          : DateTime.parse(json['oldestAt'] as String),
    );

Map<String, dynamic> _$AttentionQueueDtoToJson(AttentionQueueDto instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'count': instance.count,
      'priority': instance.priority,
      'oldestAt': instance.oldestAt?.toIso8601String(),
      'path': instance.path,
    };
