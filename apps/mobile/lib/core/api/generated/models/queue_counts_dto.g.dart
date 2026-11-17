// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_counts_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueueCountsDto _$QueueCountsDtoFromJson(Map<String, dynamic> json) =>
    QueueCountsDto(
      queue: json['queue'] as String,
      waiting: json['waiting'] as num,
      active: json['active'] as num,
      delayed: json['delayed'] as num,
      failed: json['failed'] as num,
      completed: json['completed'] as num,
    );

Map<String, dynamic> _$QueueCountsDtoToJson(QueueCountsDto instance) =>
    <String, dynamic>{
      'queue': instance.queue,
      'waiting': instance.waiting,
      'active': instance.active,
      'delayed': instance.delayed,
      'failed': instance.failed,
      'completed': instance.completed,
    };
