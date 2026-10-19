// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'own_profile_dto.dart';

part 'patch_api_v1_me_profile_response.g.dart';

@JsonSerializable()
class PatchApiV1MeProfileResponse {
  const PatchApiV1MeProfileResponse({required this.data, this.meta});

  factory PatchApiV1MeProfileResponse.fromJson(Map<String, Object?> json) =>
      _$PatchApiV1MeProfileResponseFromJson(json);

  final OwnProfileDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PatchApiV1MeProfileResponseToJson(this);
}
