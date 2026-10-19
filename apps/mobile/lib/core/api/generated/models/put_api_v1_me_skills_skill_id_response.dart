// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'skill_entry_dto.dart';

part 'put_api_v1_me_skills_skill_id_response.g.dart';

@JsonSerializable()
class PutApiV1MeSkillsSkillIdResponse {
  const PutApiV1MeSkillsSkillIdResponse({required this.data, this.meta});

  factory PutApiV1MeSkillsSkillIdResponse.fromJson(Map<String, Object?> json) =>
      _$PutApiV1MeSkillsSkillIdResponseFromJson(json);

  final SkillEntryDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PutApiV1MeSkillsSkillIdResponseToJson(this);
}
