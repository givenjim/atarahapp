// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_complete_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnboardingCompleteDto _$OnboardingCompleteDtoFromJson(
  Map<String, dynamic> json,
) => OnboardingCompleteDto(
  state: OnboardingStateDto.fromJson(json['state'] as Map<String, dynamic>),
  passport: PassportPreviewDto.fromJson(
    json['passport'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$OnboardingCompleteDtoToJson(
  OnboardingCompleteDto instance,
) => <String, dynamic>{'state': instance.state, 'passport': instance.passport};
