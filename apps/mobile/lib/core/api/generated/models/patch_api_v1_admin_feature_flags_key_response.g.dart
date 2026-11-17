// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_admin_feature_flags_key_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1AdminFeatureFlagsKeyResponse
_$PatchApiV1AdminFeatureFlagsKeyResponseFromJson(Map<String, dynamic> json) =>
    PatchApiV1AdminFeatureFlagsKeyResponse(
      data: FeatureFlagDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PatchApiV1AdminFeatureFlagsKeyResponseToJson(
  PatchApiV1AdminFeatureFlagsKeyResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
