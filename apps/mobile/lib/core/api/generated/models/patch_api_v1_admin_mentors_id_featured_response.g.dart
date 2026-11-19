// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_admin_mentors_id_featured_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1AdminMentorsIdFeaturedResponse
_$PatchApiV1AdminMentorsIdFeaturedResponseFromJson(Map<String, dynamic> json) =>
    PatchApiV1AdminMentorsIdFeaturedResponse(
      data: AdminMentorDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PatchApiV1AdminMentorsIdFeaturedResponseToJson(
  PatchApiV1AdminMentorsIdFeaturedResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
