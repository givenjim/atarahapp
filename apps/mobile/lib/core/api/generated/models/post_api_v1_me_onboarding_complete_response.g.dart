// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_onboarding_complete_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeOnboardingCompleteResponse
_$PostApiV1MeOnboardingCompleteResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1MeOnboardingCompleteResponse(
      data: OnboardingCompleteDto.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1MeOnboardingCompleteResponseToJson(
  PostApiV1MeOnboardingCompleteResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
