// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'continue_learning_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContinueLearningDto _$ContinueLearningDtoFromJson(Map<String, dynamic> json) =>
    ContinueLearningDto(
      content: LearningCardDto.fromJson(
        json['content'] as Map<String, dynamic>,
      ),
      percent: json['percent'] as num,
      lessonsDone: json['lessonsDone'] as num,
      lessonCount: json['lessonCount'] as num,
      nextLessonId: json['nextLessonId'] as String?,
      nextLessonTitle: json['nextLessonTitle'] as String?,
    );

Map<String, dynamic> _$ContinueLearningDtoToJson(
  ContinueLearningDto instance,
) => <String, dynamic>{
  'content': instance.content,
  'percent': instance.percent,
  'lessonsDone': instance.lessonsDone,
  'lessonCount': instance.lessonCount,
  'nextLessonId': instance.nextLessonId,
  'nextLessonTitle': instance.nextLessonTitle,
};
