// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'queue_counts_dto.g.dart';

@JsonSerializable()
class QueueCountsDto {
  const QueueCountsDto({
    required this.queue,
    required this.waiting,
    required this.active,
    required this.delayed,
    required this.failed,
    required this.completed,
  });
  
  factory QueueCountsDto.fromJson(Map<String, Object?> json) => _$QueueCountsDtoFromJson(json);
  
  final String queue;
  final num waiting;
  final num active;
  final num delayed;
  final num failed;
  final num completed;

  Map<String, Object?> toJson() => _$QueueCountsDtoToJson(this);
}
