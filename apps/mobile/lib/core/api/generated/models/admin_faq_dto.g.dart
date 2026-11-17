// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_faq_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminFaqDto _$AdminFaqDtoFromJson(Map<String, dynamic> json) => AdminFaqDto(
  id: json['id'] as String,
  question: json['question'] as String,
  answer: json['answer'] as String,
  sortOrder: json['sortOrder'] as num,
  published: json['published'] as bool,
);

Map<String, dynamic> _$AdminFaqDtoToJson(AdminFaqDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'answer': instance.answer,
      'sortOrder': instance.sortOrder,
      'published': instance.published,
    };
