// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'unread_count_dto.g.dart';

@JsonSerializable()
class UnreadCountDto {
  const UnreadCountDto({required this.unread, required this.byCategory});

  factory UnreadCountDto.fromJson(Map<String, Object?> json) =>
      _$UnreadCountDtoFromJson(json);

  final num unread;

  /// Unread per category.
  final Map<String, num> byCategory;

  Map<String, Object?> toJson() => _$UnreadCountDtoToJson(this);
}
