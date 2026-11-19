// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'article_block_input_dto.dart';

part 'lesson_fields_dto.g.dart';

@JsonSerializable()
class LessonFieldsDto {
  const LessonFieldsDto({
    required this.title,
    this.durationMinutes,
    this.body,
    this.videoMediaId,
    this.embedUrl,
    this.practicePrompt,
    this.practiceSkillId,
  });
  
  factory LessonFieldsDto.fromJson(Map<String, Object?> json) => _$LessonFieldsDtoFromJson(json);
  
  final String title;
  final num? durationMinutes;
  final List<ArticleBlockInputDto>? body;

  /// A READY video you uploaded through /media.
  final String? videoMediaId;

  /// Allow-listed https player address.
  final String? embedUrl;
  final String? practicePrompt;
  final String? practiceSkillId;

  Map<String, Object?> toJson() => _$LessonFieldsDtoToJson(this);
}
