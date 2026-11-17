// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'legal_document_type.dart';

part 'new_legal_version_dto.g.dart';

@JsonSerializable()
class NewLegalVersionDto {
  const NewLegalVersionDto({
    required this.type,
    required this.version,
    required this.title,
    required this.body,
  });

  factory NewLegalVersionDto.fromJson(Map<String, Object?> json) =>
      _$NewLegalVersionDtoFromJson(json);

  final LegalDocumentType type;
  final String version;
  final String title;

  /// The full text.
  final String body;

  Map<String, Object?> toJson() => _$NewLegalVersionDtoToJson(this);
}
