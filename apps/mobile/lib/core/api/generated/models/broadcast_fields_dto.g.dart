// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broadcast_fields_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BroadcastFieldsDto _$BroadcastFieldsDtoFromJson(Map<String, dynamic> json) =>
    BroadcastFieldsDto(
      title: json['title'] as String,
      body: json['body'] as String,
      target: BroadcastTarget.fromJson(json['target'] as String),
      category: json['category'] == null
          ? NotificationCategory.system
          : NotificationCategory.fromJson(json['category'] as String),
      deepLink: json['deepLink'] as String?,
      targetValue: json['targetValue'] as String?,
      scheduledAt: json['scheduledAt'] == null
          ? null
          : DateTime.parse(json['scheduledAt'] as String),
    );

Map<String, dynamic> _$BroadcastFieldsDtoToJson(BroadcastFieldsDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'body': instance.body,
      'deepLink': instance.deepLink,
      'category': instance.category,
      'target': instance.target,
      'targetValue': instance.targetValue,
      'scheduledAt': instance.scheduledAt?.toIso8601String(),
    };
