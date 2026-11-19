// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'article_block_dto.dart';

part 'admin_lesson_dto.g.dart';

@JsonSerializable()
class AdminLessonDto {
  const AdminLessonDto({
    required this.id,
    required this.sequence,
    required this.title,
    required this.durationMinutes,
    required this.body,
    this.videoMediaId,
    this.videoStatus,
    this.embedUrl,
    this.practicePrompt,
    this.practiceSkillId,
  });
  
  factory AdminLessonDto.fromJson(Map<String, Object?> json) => _$AdminLessonDtoFromJson(json);
  
  final String id;
  final num sequence;
  final String title;
  final num durationMinutes;
  final List<ArticleBlockDto> body;
  final String? videoMediaId;
  final String? videoStatus;
  final String? embedUrl;
  final String? practicePrompt;
  final String? practiceSkillId;

  Map<String, Object?> toJson() => _$AdminLessonDtoToJson(this);
}
