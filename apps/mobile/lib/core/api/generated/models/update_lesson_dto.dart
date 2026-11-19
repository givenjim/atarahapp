// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'article_block_input_dto.dart';

part 'update_lesson_dto.g.dart';

@JsonSerializable()
class UpdateLessonDto {
  const UpdateLessonDto({
    this.title,
    this.durationMinutes,
    this.body,
    this.videoMediaId,
    this.embedUrl,
    this.practicePrompt,
    this.practiceSkillId,
  });
  
  factory UpdateLessonDto.fromJson(Map<String, Object?> json) => _$UpdateLessonDtoFromJson(json);
  
  final String? title;
  final num? durationMinutes;
  final List<ArticleBlockInputDto>? body;
  final String? videoMediaId;
  final String? embedUrl;
  final String? practicePrompt;
  final String? practiceSkillId;

  Map<String, Object?> toJson() => _$UpdateLessonDtoToJson(this);
}
