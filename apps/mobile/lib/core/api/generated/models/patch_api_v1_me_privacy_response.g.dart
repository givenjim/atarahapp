// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_me_privacy_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1MePrivacyResponse _$PatchApiV1MePrivacyResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1MePrivacyResponse(
  data: PrivacyDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1MePrivacyResponseToJson(
  PatchApiV1MePrivacyResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
