// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'import_issue_dto.dart';

part 'import_commit_result_dto.g.dart';

@JsonSerializable()
class ImportCommitResultDto {
  const ImportCommitResultDto({
    required this.created,
    required this.skipped,
    required this.status,
    required this.issues,
  });
  
  factory ImportCommitResultDto.fromJson(Map<String, Object?> json) => _$ImportCommitResultDtoFromJson(json);
  
  final num created;
  final num skipped;

  /// Always DRAFT: an import never publishes.
  final String status;
  final List<ImportIssueDto> issues;

  Map<String, Object?> toJson() => _$ImportCommitResultDtoToJson(this);
}
