// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationItemDto _$NotificationItemDtoFromJson(Map<String, dynamic> json) =>
    NotificationItemDto(
      id: json['id'] as String,
      category: NotificationCategory.fromJson(json['category'] as String),
      title: json['title'] as String,
      body: json['body'] as String,
      read: json['read'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      group: NotificationItemDtoGroup.fromJson(json['group'] as String),
      type: json['type'] as String?,
      deepLink: json['deepLink'] as String?,
      data: json['data'],
    );

Map<String, dynamic> _$NotificationItemDtoToJson(
  NotificationItemDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'category': instance.category,
  'type': instance.type,
  'title': instance.title,
  'body': instance.body,
  'deepLink': instance.deepLink,
  'data': instance.data,
  'read': instance.read,
  'createdAt': instance.createdAt.toIso8601String(),
  'group': instance.group,
};
