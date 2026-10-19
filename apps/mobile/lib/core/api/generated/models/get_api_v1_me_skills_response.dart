// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'skill_entry_dto.dart';

part 'get_api_v1_me_skills_response.g.dart';

@JsonSerializable()
class GetApiV1MeSkillsResponse {
  const GetApiV1MeSkillsResponse({required this.data, this.meta});

  factory GetApiV1MeSkillsResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1MeSkillsResponseFromJson(json);

  final List<SkillEntryDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeSkillsResponseToJson(this);
}
