// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'import_issue_dto.dart';
import 'import_preview_row_dto.dart';

part 'import_report_dto.g.dart';

@JsonSerializable()
class ImportReportDto {
  const ImportReportDto({
    required this.totalCount,
    required this.validCount,
    required this.issues,
    required this.preview,
  });

  factory ImportReportDto.fromJson(Map<String, Object?> json) =>
      _$ImportReportDtoFromJson(json);

  final num totalCount;
  final num validCount;
  final List<ImportIssueDto> issues;
  final List<ImportPreviewRowDto> preview;

  Map<String, Object?> toJson() => _$ImportReportDtoToJson(this);
}
