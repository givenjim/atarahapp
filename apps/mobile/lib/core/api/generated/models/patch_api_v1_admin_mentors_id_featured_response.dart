// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_mentor_dto.dart';

part 'patch_api_v1_admin_mentors_id_featured_response.g.dart';

@JsonSerializable()
class PatchApiV1AdminMentorsIdFeaturedResponse {
  const PatchApiV1AdminMentorsIdFeaturedResponse({
    required this.data,
    this.meta,
  });
  
  factory PatchApiV1AdminMentorsIdFeaturedResponse.fromJson(Map<String, Object?> json) => _$PatchApiV1AdminMentorsIdFeaturedResponseFromJson(json);
  
  final AdminMentorDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PatchApiV1AdminMentorsIdFeaturedResponseToJson(this);
}
