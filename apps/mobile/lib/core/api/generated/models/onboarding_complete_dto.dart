// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'onboarding_state_dto.dart';
import 'passport_preview_dto.dart';

part 'onboarding_complete_dto.g.dart';

@JsonSerializable()
class OnboardingCompleteDto {
  const OnboardingCompleteDto({required this.state, required this.passport});

  factory OnboardingCompleteDto.fromJson(Map<String, Object?> json) =>
      _$OnboardingCompleteDtoFromJson(json);

  final OnboardingStateDto state;
  final PassportPreviewDto passport;

  Map<String, Object?> toJson() => _$OnboardingCompleteDtoToJson(this);
}
