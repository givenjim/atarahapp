// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_report_dto.dart';

part 'get_api_v1_admin_reports_response.g.dart';

@JsonSerializable()
class GetApiV1AdminReportsResponse {
  const GetApiV1AdminReportsResponse({required this.data, this.meta});

  factory GetApiV1AdminReportsResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1AdminReportsResponseFromJson(json);

  final List<AdminReportDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminReportsResponseToJson(this);
}
