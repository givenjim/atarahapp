// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_analytics_row_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LearningAnalyticsRowDto _$LearningAnalyticsRowDtoFromJson(
  Map<String, dynamic> json,
) => LearningAnalyticsRowDto(
  contentId: json['contentId'] as String,
  title: json['title'] as String,
  type: LearningContentType.fromJson(json['type'] as String),
  starts: json['starts'] as num,
  completions: json['completions'] as num,
  completionRate: json['completionRate'] as num,
);

Map<String, dynamic> _$LearningAnalyticsRowDtoToJson(
  LearningAnalyticsRowDto instance,
) => <String, dynamic>{
  'contentId': instance.contentId,
  'title': instance.title,
  'type': instance.type,
  'starts': instance.starts,
  'completions': instance.completions,
  'completionRate': instance.completionRate,
};
