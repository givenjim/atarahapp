// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'my_mentor_dto.dart';

part 'get_api_v1_me_mentor_response.g.dart';

@JsonSerializable()
class GetApiV1MeMentorResponse {
  const GetApiV1MeMentorResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1MeMentorResponse.fromJson(Map<String, Object?> json) => _$GetApiV1MeMentorResponseFromJson(json);
  
  final MyMentorDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeMentorResponseToJson(this);
}
