// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_me_profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1MeProfileResponse _$PatchApiV1MeProfileResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1MeProfileResponse(
  data: OwnProfileDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1MeProfileResponseToJson(
  PatchApiV1MeProfileResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
