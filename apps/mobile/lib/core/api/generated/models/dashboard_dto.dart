// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'attention_queue_dto.dart';
import 'dashboard_counts_dto.dart';

part 'dashboard_dto.g.dart';

@JsonSerializable()
class DashboardDto {
  const DashboardDto({
    required this.generatedAt,
    required this.queues,
    required this.counts,
  });

  factory DashboardDto.fromJson(Map<String, Object?> json) =>
      _$DashboardDtoFromJson(json);

  final DateTime generatedAt;

  /// Only the queues the signed-in admin may act on, most urgent first.
  final List<AttentionQueueDto> queues;
  final DashboardCountsDto counts;

  Map<String, Object?> toJson() => _$DashboardDtoToJson(this);
}
