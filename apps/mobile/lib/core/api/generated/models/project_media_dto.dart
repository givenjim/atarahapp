// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'project_media_dto_kind.dart';
import 'project_media_dto_status.dart';

part 'project_media_dto.g.dart';

@JsonSerializable()
class ProjectMediaDto {
  const ProjectMediaDto({
    required this.id,
    required this.kind,
    required this.mimeType,
    required this.status,
    this.url,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.caption,
  });

  factory ProjectMediaDto.fromJson(Map<String, Object?> json) =>
      _$ProjectMediaDtoFromJson(json);

  final String id;
  final ProjectMediaDtoKind kind;
  final String mimeType;
  final ProjectMediaDtoStatus status;

  /// Signed URL; READY only.
  final String? url;

  /// 600 px image rendition.
  final String? thumbnailUrl;
  final num? width;
  final num? height;
  final String? caption;

  Map<String, Object?> toJson() => _$ProjectMediaDtoToJson(this);
}
