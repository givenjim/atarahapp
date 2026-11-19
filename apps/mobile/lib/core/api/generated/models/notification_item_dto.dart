// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'notification_category.dart';
import 'notification_item_dto_group.dart';

part 'notification_item_dto.g.dart';

@JsonSerializable()
class NotificationItemDto {
  const NotificationItemDto({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
    required this.group,
    this.type,
    this.deepLink,
    this.data,
  });
  
  factory NotificationItemDto.fromJson(Map<String, Object?> json) => _$NotificationItemDtoFromJson(json);
  
  final String id;
  final NotificationCategory category;

  /// Dotted key, e.g. opportunity.reminder.
  final String? type;
  final String title;
  final String body;

  /// An in-app path the notification opens.
  final String? deepLink;
  final dynamic data;
  final bool read;
  final DateTime createdAt;

  /// By the Nairobi calendar day.
  final NotificationItemDtoGroup group;

  Map<String, Object?> toJson() => _$NotificationItemDtoToJson(this);
}
