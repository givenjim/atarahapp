// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unread_count_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnreadCountDto _$UnreadCountDtoFromJson(Map<String, dynamic> json) =>
    UnreadCountDto(
      unread: json['unread'] as num,
      byCategory: Map<String, num>.from(json['byCategory'] as Map),
    );

Map<String, dynamic> _$UnreadCountDtoToJson(UnreadCountDto instance) =>
    <String, dynamic>{
      'unread': instance.unread,
      'byCategory': instance.byCategory,
    };
