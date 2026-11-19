// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'marked_read_dto.g.dart';

@JsonSerializable()
class MarkedReadDto {
  const MarkedReadDto({
    required this.unread,
    required this.marked,
  });
  
  factory MarkedReadDto.fromJson(Map<String, Object?> json) => _$MarkedReadDtoFromJson(json);
  
  final num unread;
  final num marked;

  Map<String, Object?> toJson() => _$MarkedReadDtoToJson(this);
}
