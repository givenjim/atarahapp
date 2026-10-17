// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'media_asset_dto_bucket.dart';
import 'media_asset_dto_kind.dart';
import 'media_asset_dto_status.dart';

part 'media_asset_dto.g.dart';

@JsonSerializable()
class MediaAssetDto {
  const MediaAssetDto({
    required this.id,
    required this.kind,
    required this.bucket,
    required this.status,
    required this.mimeType,
    required this.sizeBytes,
    required this.createdAt,
    this.width,
    this.height,
    this.rejectionReason,
    this.url,
    this.variants,
  });

  factory MediaAssetDto.fromJson(Map<String, Object?> json) =>
      _$MediaAssetDtoFromJson(json);

  final String id;
  final MediaAssetDtoKind kind;
  final MediaAssetDtoBucket bucket;
  final MediaAssetDtoStatus status;
  final String mimeType;
  final num sizeBytes;
  final num? width;
  final num? height;

  /// Why the file was refused.
  final String? rejectionReason;

  /// Short-lived signed download URL. Present only when the file is READY.
  final String? url;

  /// Image renditions by width (200, 600, 1200) as signed URLs.
  final Map<String, String>? variants;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$MediaAssetDtoToJson(this);
}
