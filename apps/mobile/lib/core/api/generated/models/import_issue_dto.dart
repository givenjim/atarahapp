// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'import_issue_dto.g.dart';

@JsonSerializable()
class ImportIssueDto {
  const ImportIssueDto({
    required this.line,
    required this.message,
    this.column,
  });
  
  factory ImportIssueDto.fromJson(Map<String, Object?> json) => _$ImportIssueDtoFromJson(json);
  
  final num line;
  final String? column;
  final String message;

  Map<String, Object?> toJson() => _$ImportIssueDtoToJson(this);
}
