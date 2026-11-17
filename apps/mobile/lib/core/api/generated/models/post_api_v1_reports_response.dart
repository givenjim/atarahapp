// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'my_report_dto.dart';

part 'post_api_v1_reports_response.g.dart';

@JsonSerializable()
class PostApiV1ReportsResponse {
  const PostApiV1ReportsResponse({required this.data, this.meta});

  factory PostApiV1ReportsResponse.fromJson(Map<String, Object?> json) =>
      _$PostApiV1ReportsResponseFromJson(json);

  final MyReportDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1ReportsResponseToJson(this);
}
