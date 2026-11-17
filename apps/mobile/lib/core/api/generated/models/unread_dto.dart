// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'unread_dto.g.dart';

@JsonSerializable()
class UnreadDto {
  const UnreadDto({required this.unread});

  factory UnreadDto.fromJson(Map<String, Object?> json) =>
      _$UnreadDtoFromJson(json);

  final num unread;

  Map<String, Object?> toJson() => _$UnreadDtoToJson(this);
}
