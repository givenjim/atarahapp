// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'feature_flag_dto.dart';

part 'get_api_v1_admin_feature_flags_response.g.dart';

@JsonSerializable()
class GetApiV1AdminFeatureFlagsResponse {
  const GetApiV1AdminFeatureFlagsResponse({required this.data, this.meta});

  factory GetApiV1AdminFeatureFlagsResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1AdminFeatureFlagsResponseFromJson(json);

  final List<FeatureFlagDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1AdminFeatureFlagsResponseToJson(this);
}
