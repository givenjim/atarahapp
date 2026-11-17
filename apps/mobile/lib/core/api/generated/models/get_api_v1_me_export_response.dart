// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'export_state_dto.dart';

part 'get_api_v1_me_export_response.g.dart';

@JsonSerializable()
class GetApiV1MeExportResponse {
  const GetApiV1MeExportResponse({required this.data, this.meta});

  factory GetApiV1MeExportResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1MeExportResponseFromJson(json);

  final ExportStateDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeExportResponseToJson(this);
}
