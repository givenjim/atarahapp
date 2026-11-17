// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PracticeDto _$PracticeDtoFromJson(Map<String, dynamic> json) => PracticeDto(
  prompt: json['prompt'] as String,
  skill: json['skill'] == null
      ? null
      : SkillRefDto.fromJson(json['skill'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PracticeDtoToJson(PracticeDto instance) =>
    <String, dynamic>{'prompt': instance.prompt, 'skill': instance.skill};
