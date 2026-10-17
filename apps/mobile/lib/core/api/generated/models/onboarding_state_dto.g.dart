// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_state_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnboardingStateDto _$OnboardingStateDtoFromJson(Map<String, dynamic> json) =>
    OnboardingStateDto(
      step: OnboardingStateDtoStep.fromJson(json['step'] as String),
      completed: json['completed'] as bool,
      profile: OnboardingProfileDto.fromJson(
        json['profile'] as Map<String, dynamic>,
      ),
      completion: CompletionDto.fromJson(
        json['completion'] as Map<String, dynamic>,
      ),
      passportNumber: json['passportNumber'] as String?,
    );

Map<String, dynamic> _$OnboardingStateDtoToJson(OnboardingStateDto instance) =>
    <String, dynamic>{
      'step': instance.step,
      'completed': instance.completed,
      'profile': instance.profile,
      'completion': instance.completion,
      'passportNumber': instance.passportNumber,
    };
