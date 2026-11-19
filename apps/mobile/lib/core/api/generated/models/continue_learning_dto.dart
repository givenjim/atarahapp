// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'learning_card_dto.dart';

part 'continue_learning_dto.g.dart';

@JsonSerializable()
class ContinueLearningDto {
  const ContinueLearningDto({
    required this.content,
    required this.percent,
    required this.lessonsDone,
    required this.lessonCount,
    this.nextLessonId,
    this.nextLessonTitle,
  });
  
  factory ContinueLearningDto.fromJson(Map<String, Object?> json) => _$ContinueLearningDtoFromJson(json);
  
  final LearningCardDto content;
  final num percent;
  final num lessonsDone;
  final num lessonCount;
  final String? nextLessonId;
  final String? nextLessonTitle;

  Map<String, Object?> toJson() => _$ContinueLearningDtoToJson(this);
}
