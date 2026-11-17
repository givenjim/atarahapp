// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'account_preferences_dto.dart';

part 'patch_api_v1_me_preferences_response.g.dart';

@JsonSerializable()
class PatchApiV1MePreferencesResponse {
  const PatchApiV1MePreferencesResponse({required this.data, this.meta});

  factory PatchApiV1MePreferencesResponse.fromJson(Map<String, Object?> json) =>
      _$PatchApiV1MePreferencesResponseFromJson(json);

  final AccountPreferencesDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PatchApiV1MePreferencesResponseToJson(this);
}
