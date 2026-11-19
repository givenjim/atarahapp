// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'my_mentor_dto.dart';

part 'put_api_v1_me_mentor_paused_response.g.dart';

@JsonSerializable()
class PutApiV1MeMentorPausedResponse {
  const PutApiV1MeMentorPausedResponse({
    required this.data,
    this.meta,
  });
  
  factory PutApiV1MeMentorPausedResponse.fromJson(Map<String, Object?> json) => _$PutApiV1MeMentorPausedResponseFromJson(json);
  
  final MyMentorDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PutApiV1MeMentorPausedResponseToJson(this);
}
