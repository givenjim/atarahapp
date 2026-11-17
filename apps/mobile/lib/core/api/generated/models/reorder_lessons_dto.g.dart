// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reorder_lessons_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReorderLessonsDto _$ReorderLessonsDtoFromJson(Map<String, dynamic> json) =>
    ReorderLessonsDto(
      lessonIds: (json['lessonIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ReorderLessonsDtoToJson(ReorderLessonsDto instance) =>
    <String, dynamic>{'lessonIds': instance.lessonIds};
