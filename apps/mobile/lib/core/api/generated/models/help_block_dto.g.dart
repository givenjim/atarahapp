// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'help_block_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HelpBlockDto _$HelpBlockDtoFromJson(Map<String, dynamic> json) => HelpBlockDto(
  type: HelpBlockDtoType.fromJson(json['type'] as String),
  text: json['text'] as String?,
  title: json['title'] as String?,
  attribution: json['attribution'] as String?,
);

Map<String, dynamic> _$HelpBlockDtoToJson(HelpBlockDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'text': instance.text,
      'title': instance.title,
      'attribution': instance.attribution,
    };
