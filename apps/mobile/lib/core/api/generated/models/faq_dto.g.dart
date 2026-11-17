// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faq_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FaqDto _$FaqDtoFromJson(Map<String, dynamic> json) => FaqDto(
  id: json['id'] as String,
  question: json['question'] as String,
  answer: json['answer'] as String,
);

Map<String, dynamic> _$FaqDtoToJson(FaqDto instance) => <String, dynamic>{
  'id': instance.id,
  'question': instance.question,
  'answer': instance.answer,
};
