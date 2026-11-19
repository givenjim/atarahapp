// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_mentor_dto.dart';

part 'get_api_v1_admin_mentors_response.g.dart';

@JsonSerializable()
class GetApiV1AdminMentorsResponse {
  const GetApiV1AdminMentorsResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1AdminMentorsResponse.fromJson(Map<String, Object?> json) => _$GetApiV1AdminMentorsResponseFromJson(json);
  
  final List<AdminMentorDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminMentorsResponseToJson(this);
}
