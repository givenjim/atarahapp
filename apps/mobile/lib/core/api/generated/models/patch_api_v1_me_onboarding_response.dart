// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'onboarding_state_dto.dart';

part 'patch_api_v1_me_onboarding_response.g.dart';

@JsonSerializable()
class PatchApiV1MeOnboardingResponse {
  const PatchApiV1MeOnboardingResponse({required this.data, this.meta});

  factory PatchApiV1MeOnboardingResponse.fromJson(Map<String, Object?> json) =>
      _$PatchApiV1MeOnboardingResponseFromJson(json);

  final OnboardingStateDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PatchApiV1MeOnboardingResponseToJson(this);
}
