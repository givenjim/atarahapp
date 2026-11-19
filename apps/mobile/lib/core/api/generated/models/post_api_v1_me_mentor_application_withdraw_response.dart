// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'mentor_application_dto.dart';

part 'post_api_v1_me_mentor_application_withdraw_response.g.dart';

@JsonSerializable()
class PostApiV1MeMentorApplicationWithdrawResponse {
  const PostApiV1MeMentorApplicationWithdrawResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1MeMentorApplicationWithdrawResponse.fromJson(Map<String, Object?> json) => _$PostApiV1MeMentorApplicationWithdrawResponseFromJson(json);
  
  final MentorApplicationDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MeMentorApplicationWithdrawResponseToJson(this);
}
