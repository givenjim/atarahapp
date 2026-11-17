// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'broadcast_target.dart';
import 'notification_category.dart';

part 'broadcast_fields_dto.g.dart';

@JsonSerializable()
class BroadcastFieldsDto {
  const BroadcastFieldsDto({
    required this.title,
    required this.body,
    required this.target,
    this.category = NotificationCategory.system,
    this.deepLink,
    this.targetValue,
    this.scheduledAt,
  });

  factory BroadcastFieldsDto.fromJson(Map<String, Object?> json) =>
      _$BroadcastFieldsDtoFromJson(json);

  final String title;
  final String body;

  /// An in-app path the notification opens, e.g. /opportunities.
  final String? deepLink;
  final NotificationCategory category;
  final BroadcastTarget target;

  /// The role key, discipline id or county id, by `target`. Not used for ALL.
  final String? targetValue;

  /// Send then. Omit to send right away.
  final DateTime? scheduledAt;

  Map<String, Object?> toJson() => _$BroadcastFieldsDtoToJson(this);
}
