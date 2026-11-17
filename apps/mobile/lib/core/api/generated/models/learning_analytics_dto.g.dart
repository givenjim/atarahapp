// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_analytics_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LearningAnalyticsDto _$LearningAnalyticsDtoFromJson(
  Map<String, dynamic> json,
) => LearningAnalyticsDto(
  publishedItems: json['publishedItems'] as num,
  totalStarts: json['totalStarts'] as num,
  totalCompletions: json['totalCompletions'] as num,
  certificatesIssued: json['certificatesIssued'] as num,
  items: (json['items'] as List<dynamic>)
      .map((e) => LearningAnalyticsRowDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LearningAnalyticsDtoToJson(
  LearningAnalyticsDto instance,
) => <String, dynamic>{
  'publishedItems': instance.publishedItems,
  'totalStarts': instance.totalStarts,
  'totalCompletions': instance.totalCompletions,
  'certificatesIssued': instance.certificatesIssued,
  'items': instance.items,
};
