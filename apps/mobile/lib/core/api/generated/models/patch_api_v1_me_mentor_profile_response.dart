// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'my_mentor_dto.dart';

part 'patch_api_v1_me_mentor_profile_response.g.dart';

@JsonSerializable()
class PatchApiV1MeMentorProfileResponse {
  const PatchApiV1MeMentorProfileResponse({
    required this.data,
    this.meta,
  });
  
  factory PatchApiV1MeMentorProfileResponse.fromJson(Map<String, Object?> json) => _$PatchApiV1MeMentorProfileResponseFromJson(json);
  
  final MyMentorDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PatchApiV1MeMentorProfileResponseToJson(this);
}
