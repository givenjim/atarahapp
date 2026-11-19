// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'mentor_detail_dto.dart';

part 'get_api_v1_mentors_id_response.g.dart';

@JsonSerializable()
class GetApiV1MentorsIdResponse {
  const GetApiV1MentorsIdResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1MentorsIdResponse.fromJson(Map<String, Object?> json) => _$GetApiV1MentorsIdResponseFromJson(json);
  
  final MentorDetailDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MentorsIdResponseToJson(this);
}
