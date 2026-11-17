// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'broadcast_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BroadcastDto _$BroadcastDtoFromJson(Map<String, dynamic> json) => BroadcastDto(
  id: json['id'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  category: NotificationCategory.fromJson(json['category'] as String),
  target: BroadcastTarget.fromJson(json['target'] as String),
  status: BroadcastStatus.fromJson(json['status'] as String),
  recipientCount: json['recipientCount'] as num,
  createdAt: DateTime.parse(json['createdAt'] as String),
  deepLink: json['deepLink'] as String?,
  targetValue: json['targetValue'] as String?,
  targetLabel: json['targetLabel'] as String?,
  scheduledAt: json['scheduledAt'] == null
      ? null
      : DateTime.parse(json['scheduledAt'] as String),
  sentAt: json['sentAt'] == null
      ? null
      : DateTime.parse(json['sentAt'] as String),
);

Map<String, dynamic> _$BroadcastDtoToJson(BroadcastDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'deepLink': instance.deepLink,
      'category': instance.category,
      'target': instance.target,
      'targetValue': instance.targetValue,
      'targetLabel': instance.targetLabel,
      'scheduledAt': instance.scheduledAt?.toIso8601String(),
      'status': instance.status,
      'recipientCount': instance.recipientCount,
      'sentAt': instance.sentAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
