// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'skill_entry_dto.dart';

part 'get_api_v1_creatives_handle_skills_response.g.dart';

@JsonSerializable()
class GetApiV1CreativesHandleSkillsResponse {
  const GetApiV1CreativesHandleSkillsResponse({required this.data, this.meta});

  factory GetApiV1CreativesHandleSkillsResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1CreativesHandleSkillsResponseFromJson(json);

  final List<SkillEntryDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1CreativesHandleSkillsResponseToJson(this);
}
