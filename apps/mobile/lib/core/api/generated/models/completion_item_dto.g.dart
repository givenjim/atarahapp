// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completion_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompletionItemDto _$CompletionItemDtoFromJson(Map<String, dynamic> json) =>
    CompletionItemDto(
      key: json['key'] as String,
      label: json['label'] as String,
      weight: json['weight'] as num,
      done: json['done'] as bool,
    );

Map<String, dynamic> _$CompletionItemDtoToJson(CompletionItemDto instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'weight': instance.weight,
      'done': instance.done,
    };
