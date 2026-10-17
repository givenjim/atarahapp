// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'onboarding_complete_dto.dart';

part 'post_api_v1_me_onboarding_complete_response.g.dart';

@JsonSerializable()
class PostApiV1MeOnboardingCompleteResponse {
  const PostApiV1MeOnboardingCompleteResponse({required this.data, this.meta});

  factory PostApiV1MeOnboardingCompleteResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1MeOnboardingCompleteResponseFromJson(json);

  final OnboardingCompleteDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1MeOnboardingCompleteResponseToJson(this);
}
