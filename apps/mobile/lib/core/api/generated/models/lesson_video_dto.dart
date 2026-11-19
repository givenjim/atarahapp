// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'lesson_video_dto.g.dart';

@JsonSerializable()
class LessonVideoDto {
  const LessonVideoDto({
    required this.url,
    required this.expiresAt,
    this.posterUrl,
    this.durationSeconds,
  });
  
  factory LessonVideoDto.fromJson(Map<String, Object?> json) => _$LessonVideoDtoFromJson(json);
  
  /// Short-lived signed address of the MP4.
  final String url;
  final String? posterUrl;
  final DateTime expiresAt;
  final num? durationSeconds;

  Map<String, Object?> toJson() => _$LessonVideoDtoToJson(this);
}
