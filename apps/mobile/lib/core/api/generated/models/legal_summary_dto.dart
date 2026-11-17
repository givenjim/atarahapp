// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'legal_document_type.dart';

part 'legal_summary_dto.g.dart';

@JsonSerializable()
class LegalSummaryDto {
  const LegalSummaryDto({
    required this.type,
    required this.title,
    required this.version,
    required this.isDraft,
    this.effectiveAt,
    this.draftLabel,
  });

  factory LegalSummaryDto.fromJson(Map<String, Object?> json) =>
      _$LegalSummaryDtoFromJson(json);

  final LegalDocumentType type;
  final String title;
  final String version;
  final DateTime? effectiveAt;
  final bool isDraft;

  /// Shown while the text is a draft.
  final String? draftLabel;

  Map<String, Object?> toJson() => _$LegalSummaryDtoToJson(this);
}
