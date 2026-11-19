// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'notification_category.dart';

part 'mark_all_read_dto.g.dart';

@JsonSerializable()
class MarkAllReadDto {
  const MarkAllReadDto({
    required this.category,
  });
  
  factory MarkAllReadDto.fromJson(Map<String, Object?> json) => _$MarkAllReadDtoFromJson(json);
  
  /// Only this category.
  final NotificationCategory category;

  Map<String, Object?> toJson() => _$MarkAllReadDtoToJson(this);
}
