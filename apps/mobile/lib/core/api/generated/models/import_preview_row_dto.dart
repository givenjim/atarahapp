// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'opportunity_type.dart';

part 'import_preview_row_dto.g.dart';

@JsonSerializable()
class ImportPreviewRowDto {
  const ImportPreviewRowDto({
    required this.line,
    required this.title,
    required this.provider,
    required this.type,
    required this.providerExists,
    this.deadlineAt,
  });
  
  factory ImportPreviewRowDto.fromJson(Map<String, Object?> json) => _$ImportPreviewRowDtoFromJson(json);
  
  final num line;
  final String title;
  final String provider;
  final OpportunityType type;
  final DateTime? deadlineAt;

  /// The provider already exists; otherwise a new one is created.
  final bool providerExists;

  Map<String, Object?> toJson() => _$ImportPreviewRowDtoToJson(this);
}
