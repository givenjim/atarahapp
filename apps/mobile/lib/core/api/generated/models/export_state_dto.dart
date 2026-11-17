// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'export_state_dto_status.dart';

part 'export_state_dto.g.dart';

@JsonSerializable()
class ExportStateDto {
  const ExportStateDto({
    required this.status,
    this.id,
    this.requestedAt,
    this.expiresAt,
    this.downloadUrl,
    this.nextAllowedAt,
  });

  factory ExportStateDto.fromJson(Map<String, Object?> json) =>
      _$ExportStateDtoFromJson(json);

  final ExportStateDtoStatus status;
  final String? id;
  final DateTime? requestedAt;
  final DateTime? expiresAt;

  /// Signed download link, only while READY.
  final String? downloadUrl;

  /// When another export can be asked for.
  final DateTime? nextAllowedAt;

  Map<String, Object?> toJson() => _$ExportStateDtoToJson(this);
}
