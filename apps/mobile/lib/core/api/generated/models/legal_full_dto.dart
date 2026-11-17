// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'legal_document_type.dart';

part 'legal_full_dto.g.dart';

@JsonSerializable()
class LegalFullDto {
  const LegalFullDto({
    required this.type,
    required this.title,
    required this.version,
    required this.isDraft,
    required this.body,
    this.effectiveAt,
    this.draftLabel,
  });

  factory LegalFullDto.fromJson(Map<String, Object?> json) =>
      _$LegalFullDtoFromJson(json);

  final LegalDocumentType type;
  final String title;
  final String version;
  final DateTime? effectiveAt;
  final bool isDraft;

  /// Shown while the text is a draft.
  final String? draftLabel;
  final String body;

  Map<String, Object?> toJson() => _$LegalFullDtoToJson(this);
}
