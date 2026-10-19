// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_me_passport_visibility_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1MePassportVisibilityResponse
_$PatchApiV1MePassportVisibilityResponseFromJson(Map<String, dynamic> json) =>
    PatchApiV1MePassportVisibilityResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => SectionVisibilityDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$PatchApiV1MePassportVisibilityResponseToJson(
  PatchApiV1MePassportVisibilityResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
