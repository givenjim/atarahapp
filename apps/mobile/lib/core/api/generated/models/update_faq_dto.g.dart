// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_faq_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateFaqDto _$UpdateFaqDtoFromJson(Map<String, dynamic> json) => UpdateFaqDto(
  question: json['question'] as String?,
  answer: json['answer'] as String?,
  sortOrder: json['sortOrder'] as num?,
  published: json['published'] as bool?,
);

Map<String, dynamic> _$UpdateFaqDtoToJson(UpdateFaqDto instance) =>
    <String, dynamic>{
      'question': instance.question,
      'answer': instance.answer,
      'sortOrder': instance.sortOrder,
      'published': instance.published,
    };
