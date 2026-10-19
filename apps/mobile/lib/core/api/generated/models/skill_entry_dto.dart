// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'skill_entry_dto_level.dart';
import 'skill_entry_dto_source.dart';

part 'skill_entry_dto.g.dart';

@JsonSerializable()
class SkillEntryDto {
  const SkillEntryDto({
    required this.id,
    required this.slug,
    required this.name,
    required this.source,
    required this.projectCount,
    this.level,
  });

  factory SkillEntryDto.fromJson(Map<String, Object?> json) =>
      _$SkillEntryDtoFromJson(json);

  final String id;
  final String slug;
  final String name;
  final SkillEntryDtoLevel? level;
  final SkillEntryDtoSource source;

  /// Published projects of yours that use this skill.
  final num projectCount;

  Map<String, Object?> toJson() => _$SkillEntryDtoToJson(this);
}
