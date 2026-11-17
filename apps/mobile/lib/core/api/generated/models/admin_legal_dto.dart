// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_legal_dto_status.dart';
import 'legal_document_type.dart';

part 'admin_legal_dto.g.dart';

@JsonSerializable()
class AdminLegalDto {
  const AdminLegalDto({
    required this.type,
    required this.title,
    required this.version,
    required this.isDraft,
    required this.body,
    required this.id,
    required this.status,
    required this.updatedAt,
    this.effectiveAt,
    this.draftLabel,
  });

  factory AdminLegalDto.fromJson(Map<String, Object?> json) =>
      _$AdminLegalDtoFromJson(json);

  final LegalDocumentType type;
  final String title;
  final String version;
  final DateTime? effectiveAt;
  final bool isDraft;

  /// Shown while the text is a draft.
  final String? draftLabel;
  final String body;
  final String id;
  final AdminLegalDtoStatus status;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => _$AdminLegalDtoToJson(this);
}
