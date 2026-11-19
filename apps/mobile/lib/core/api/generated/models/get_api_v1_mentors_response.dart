// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'mentor_card_dto.dart';

part 'get_api_v1_mentors_response.g.dart';

@JsonSerializable()
class GetApiV1MentorsResponse {
  const GetApiV1MentorsResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1MentorsResponse.fromJson(Map<String, Object?> json) => _$GetApiV1MentorsResponseFromJson(json);
  
  final List<MentorCardDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MentorsResponseToJson(this);
}
