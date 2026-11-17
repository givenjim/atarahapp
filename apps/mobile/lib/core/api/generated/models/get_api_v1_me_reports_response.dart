// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'my_report_dto.dart';

part 'get_api_v1_me_reports_response.g.dart';

@JsonSerializable()
class GetApiV1MeReportsResponse {
  const GetApiV1MeReportsResponse({required this.data, this.meta});

  factory GetApiV1MeReportsResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1MeReportsResponseFromJson(json);

  final List<MyReportDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeReportsResponseToJson(this);
}
