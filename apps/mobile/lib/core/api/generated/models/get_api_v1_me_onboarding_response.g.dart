// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_onboarding_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeOnboardingResponse _$GetApiV1MeOnboardingResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeOnboardingResponse(
  data: OnboardingStateDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeOnboardingResponseToJson(
  GetApiV1MeOnboardingResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
