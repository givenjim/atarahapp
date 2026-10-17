// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_api_v1_me_avatar_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteApiV1MeAvatarResponse _$DeleteApiV1MeAvatarResponseFromJson(
  Map<String, dynamic> json,
) => DeleteApiV1MeAvatarResponse(
  data: OnboardingStateDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$DeleteApiV1MeAvatarResponseToJson(
  DeleteApiV1MeAvatarResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
