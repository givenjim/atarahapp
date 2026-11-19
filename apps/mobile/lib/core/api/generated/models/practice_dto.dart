// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'skill_ref_dto.dart';

part 'practice_dto.g.dart';

@JsonSerializable()
class PracticeDto {
  const PracticeDto({
    required this.prompt,
    this.skill,
  });
  
  factory PracticeDto.fromJson(Map<String, Object?> json) => _$PracticeDtoFromJson(json);
  
  final String prompt;
  final SkillRefDto? skill;

  Map<String, Object?> toJson() => _$PracticeDtoToJson(this);
}
