// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'section_visibility_dto.dart';

part 'patch_api_v1_me_passport_visibility_response.g.dart';

@JsonSerializable()
class PatchApiV1MePassportVisibilityResponse {
  const PatchApiV1MePassportVisibilityResponse({required this.data, this.meta});

  factory PatchApiV1MePassportVisibilityResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PatchApiV1MePassportVisibilityResponseFromJson(json);

  final List<SectionVisibilityDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PatchApiV1MePassportVisibilityResponseToJson(this);
}
