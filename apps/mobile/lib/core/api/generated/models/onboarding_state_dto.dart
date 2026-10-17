// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'completion_dto.dart';
import 'onboarding_profile_dto.dart';
import 'onboarding_state_dto_step.dart';

part 'onboarding_state_dto.g.dart';

@JsonSerializable()
class OnboardingStateDto {
  const OnboardingStateDto({
    required this.step,
    required this.completed,
    required this.profile,
    required this.completion,
    required this.passportNumber,
  });

  factory OnboardingStateDto.fromJson(Map<String, Object?> json) =>
      _$OnboardingStateDtoFromJson(json);

  /// The step to show next (the resume point).
  final OnboardingStateDtoStep step;

  /// True once the member finished onboarding and holds a Passport.
  final bool completed;
  final OnboardingProfileDto profile;
  final CompletionDto completion;
  final String? passportNumber;

  Map<String, Object?> toJson() => _$OnboardingStateDtoToJson(this);
}
