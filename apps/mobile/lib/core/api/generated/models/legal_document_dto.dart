// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'legal_document_dto_type.dart';

part 'legal_document_dto.g.dart';

@JsonSerializable()
class LegalDocumentDto {
  const LegalDocumentDto({
    required this.type,
    required this.version,
    required this.title,
    required this.body,
    required this.isDraft,
  });

  factory LegalDocumentDto.fromJson(Map<String, Object?> json) =>
      _$LegalDocumentDtoFromJson(json);

  final LegalDocumentDtoType type;
  final String version;
  final String title;
  final String body;

  /// True until the owner publishes reviewed text. Show it as a draft.
  final bool isDraft;

  Map<String, Object?> toJson() => _$LegalDocumentDtoToJson(this);
}
