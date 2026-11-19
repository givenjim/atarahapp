// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'exception_dto.dart';

part 'post_api_v1_me_mentor_availability_exceptions_response.g.dart';

@JsonSerializable()
class PostApiV1MeMentorAvailabilityExceptionsResponse {
  const PostApiV1MeMentorAvailabilityExceptionsResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1MeMentorAvailabilityExceptionsResponse.fromJson(Map<String, Object?> json) => _$PostApiV1MeMentorAvailabilityExceptionsResponseFromJson(json);
  
  final ExceptionDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MeMentorAvailabilityExceptionsResponseToJson(this);
}
