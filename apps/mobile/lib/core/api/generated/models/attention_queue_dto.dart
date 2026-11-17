// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'attention_queue_dto_priority.dart';

part 'attention_queue_dto.g.dart';

@JsonSerializable()
class AttentionQueueDto {
  const AttentionQueueDto({
    required this.key,
    required this.label,
    required this.count,
    required this.priority,
    required this.path,
    this.oldestAt,
  });

  factory AttentionQueueDto.fromJson(Map<String, Object?> json) =>
      _$AttentionQueueDtoFromJson(json);

  final String key;
  final String label;
  final num count;
  final AttentionQueueDtoPriority priority;

  /// The oldest item waiting.
  final DateTime? oldestAt;

  /// Console path that opens the queue.
  final String path;

  Map<String, Object?> toJson() => _$AttentionQueueDtoToJson(this);
}
