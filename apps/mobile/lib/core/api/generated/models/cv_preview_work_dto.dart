// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'cv_preview_work_dto.g.dart';

@JsonSerializable()
class CvPreviewWorkDto {
  const CvPreviewWorkDto({
    required this.title,
    this.role,
    this.year,
  });
  
  factory CvPreviewWorkDto.fromJson(Map<String, Object?> json) => _$CvPreviewWorkDtoFromJson(json);
  
  final String title;
  final String? role;
  final num? year;

  Map<String, Object?> toJson() => _$CvPreviewWorkDtoToJson(this);
}
