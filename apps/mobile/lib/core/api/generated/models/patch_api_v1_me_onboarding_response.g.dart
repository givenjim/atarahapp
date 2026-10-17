// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_me_onboarding_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1MeOnboardingResponse _$PatchApiV1MeOnboardingResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1MeOnboardingResponse(
  data: OnboardingStateDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1MeOnboardingResponseToJson(
  PatchApiV1MeOnboardingResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
