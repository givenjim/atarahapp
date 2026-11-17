// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'activity_counts_dto.g.dart';

@JsonSerializable()
class ActivityCountsDto {
  const ActivityCountsDto({
    required this.saved,
    required this.applications,
    required this.unreadNotifications,
    required this.learningInProgress,
    required this.portfolio,
    required this.pendingConnections,
  });

  factory ActivityCountsDto.fromJson(Map<String, Object?> json) =>
      _$ActivityCountsDtoFromJson(json);

  /// Saved items of every kind.
  final num saved;

  /// Tracked opportunities that are in progress, applied or completed.
  final num applications;
  final num unreadNotifications;

  /// Courses started and not finished.
  final num learningInProgress;

  /// Published projects.
  final num portfolio;

  /// Connection requests waiting for an answer.
  final num pendingConnections;

  Map<String, Object?> toJson() => _$ActivityCountsDtoToJson(this);
}
