// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completion_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompletionDto _$CompletionDtoFromJson(Map<String, dynamic> json) =>
    CompletionDto(
      percent: json['percent'] as num,
      items: (json['items'] as List<dynamic>)
          .map((e) => CompletionItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      next: (json['next'] as List<dynamic>)
          .map((e) => CompletionItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CompletionDtoToJson(CompletionDto instance) =>
    <String, dynamic>{
      'percent': instance.percent,
      'items': instance.items,
      'next': instance.next,
    };
