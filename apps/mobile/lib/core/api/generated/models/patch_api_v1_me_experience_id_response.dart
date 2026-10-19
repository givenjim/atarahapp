// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'experience_dto.dart';

part 'patch_api_v1_me_experience_id_response.g.dart';

@JsonSerializable()
class PatchApiV1MeExperienceIdResponse {
  const PatchApiV1MeExperienceIdResponse({required this.data, this.meta});

  factory PatchApiV1MeExperienceIdResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PatchApiV1MeExperienceIdResponseFromJson(json);

  final ExperienceDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PatchApiV1MeExperienceIdResponseToJson(this);
}
