// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'cv_download_dto.g.dart';

@JsonSerializable()
class CvDownloadDto {
  const CvDownloadDto({
    required this.url,
    required this.expiresAt,
  });
  
  factory CvDownloadDto.fromJson(Map<String, Object?> json) => _$CvDownloadDtoFromJson(json);
  
  /// Signed link to the private PDF; it works for a few minutes.
  final String url;
  final DateTime expiresAt;

  Map<String, Object?> toJson() => _$CvDownloadDtoToJson(this);
}
