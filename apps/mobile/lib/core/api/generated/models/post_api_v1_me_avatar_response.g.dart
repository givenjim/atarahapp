// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_avatar_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeAvatarResponse _$PostApiV1MeAvatarResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MeAvatarResponse(
  data: OnboardingStateDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MeAvatarResponseToJson(
  PostApiV1MeAvatarResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
