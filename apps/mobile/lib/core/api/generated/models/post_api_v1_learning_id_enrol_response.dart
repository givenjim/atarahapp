// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'enrolment_dto.dart';

part 'post_api_v1_learning_id_enrol_response.g.dart';

@JsonSerializable()
class PostApiV1LearningIdEnrolResponse {
  const PostApiV1LearningIdEnrolResponse({required this.data, this.meta});

  factory PostApiV1LearningIdEnrolResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1LearningIdEnrolResponseFromJson(json);

  final EnrolmentDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1LearningIdEnrolResponseToJson(this);
}
