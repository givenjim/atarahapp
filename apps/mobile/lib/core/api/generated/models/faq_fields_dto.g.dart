// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faq_fields_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FaqFieldsDto _$FaqFieldsDtoFromJson(Map<String, dynamic> json) => FaqFieldsDto(
  question: json['question'] as String,
  answer: json['answer'] as String,
  sortOrder: json['sortOrder'] as num?,
  published: json['published'] as bool?,
);

Map<String, dynamic> _$FaqFieldsDtoToJson(FaqFieldsDto instance) =>
    <String, dynamic>{
      'question': instance.question,
      'answer': instance.answer,
      'sortOrder': instance.sortOrder,
      'published': instance.published,
    };
