// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'slots_dto.dart';

part 'get_api_v1_mentors_id_slots_response.g.dart';

@JsonSerializable()
class GetApiV1MentorsIdSlotsResponse {
  const GetApiV1MentorsIdSlotsResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1MentorsIdSlotsResponse.fromJson(Map<String, Object?> json) => _$GetApiV1MentorsIdSlotsResponseFromJson(json);
  
  final SlotsDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MentorsIdSlotsResponseToJson(this);
}
