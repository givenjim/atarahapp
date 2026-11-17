// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'feature_flag_dto.dart';

part 'patch_api_v1_admin_feature_flags_key_response.g.dart';

@JsonSerializable()
class PatchApiV1AdminFeatureFlagsKeyResponse {
  const PatchApiV1AdminFeatureFlagsKeyResponse({required this.data, this.meta});

  factory PatchApiV1AdminFeatureFlagsKeyResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PatchApiV1AdminFeatureFlagsKeyResponseFromJson(json);

  final FeatureFlagDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PatchApiV1AdminFeatureFlagsKeyResponseToJson(this);
}
