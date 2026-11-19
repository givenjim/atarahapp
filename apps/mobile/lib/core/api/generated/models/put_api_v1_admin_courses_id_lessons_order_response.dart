// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_content_dto.dart';

part 'put_api_v1_admin_courses_id_lessons_order_response.g.dart';

@JsonSerializable()
class PutApiV1AdminCoursesIdLessonsOrderResponse {
  const PutApiV1AdminCoursesIdLessonsOrderResponse({
    required this.data,
    this.meta,
  });
  
  factory PutApiV1AdminCoursesIdLessonsOrderResponse.fromJson(Map<String, Object?> json) => _$PutApiV1AdminCoursesIdLessonsOrderResponseFromJson(json);
  
  final AdminContentDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PutApiV1AdminCoursesIdLessonsOrderResponseToJson(this);
}
