// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_me_mentor_profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1MeMentorProfileResponse _$PatchApiV1MeMentorProfileResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1MeMentorProfileResponse(
  data: MyMentorDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1MeMentorProfileResponseToJson(
  PatchApiV1MeMentorProfileResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
