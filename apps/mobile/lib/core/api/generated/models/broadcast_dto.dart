// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'broadcast_status.dart';
import 'broadcast_target.dart';
import 'notification_category.dart';

part 'broadcast_dto.g.dart';

@JsonSerializable()
class BroadcastDto {
  const BroadcastDto({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.target,
    required this.status,
    required this.recipientCount,
    required this.createdAt,
    this.deepLink,
    this.targetValue,
    this.targetLabel,
    this.scheduledAt,
    this.sentAt,
  });

  factory BroadcastDto.fromJson(Map<String, Object?> json) =>
      _$BroadcastDtoFromJson(json);

  final String id;
  final String title;
  final String body;
  final String? deepLink;
  final NotificationCategory category;
  final BroadcastTarget target;
  final String? targetValue;

  /// Readable target: the role, discipline or county name.
  final String? targetLabel;
  final DateTime? scheduledAt;
  final BroadcastStatus status;
  final num recipientCount;
  final DateTime? sentAt;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$BroadcastDtoToJson(this);
}
