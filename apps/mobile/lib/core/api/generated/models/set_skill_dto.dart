// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'set_skill_dto_level.dart';

part 'set_skill_dto.g.dart';

@JsonSerializable()
class SetSkillDto {
  const SetSkillDto({required this.level});

  factory SetSkillDto.fromJson(Map<String, Object?> json) =>
      _$SetSkillDtoFromJson(json);

  final SetSkillDtoLevel level;

  Map<String, Object?> toJson() => _$SetSkillDtoToJson(this);
}
