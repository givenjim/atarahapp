// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_render_dto_status.dart';

part 'cv_render_dto.g.dart';

@JsonSerializable()
class CvRenderDto {
  const CvRenderDto({
    required this.id,
    required this.status,
    required this.requestedAt,
    this.readyAt,
    this.error,
  });
  
  factory CvRenderDto.fromJson(Map<String, Object?> json) => _$CvRenderDtoFromJson(json);
  
  final String id;
  final CvRenderDtoStatus status;
  final DateTime requestedAt;
  final DateTime? readyAt;

  /// Plain-language reason when FAILED.
  final String? error;

  Map<String, Object?> toJson() => _$CvRenderDtoToJson(this);
}
