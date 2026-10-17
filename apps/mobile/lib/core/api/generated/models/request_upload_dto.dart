// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'request_upload_dto_kind.dart';
import 'request_upload_dto_visibility.dart';

part 'request_upload_dto.g.dart';

@JsonSerializable()
class RequestUploadDto {
  const RequestUploadDto({
    required this.kind,
    required this.mimeType,
    required this.sizeBytes,
    required this.visibility,
  });

  factory RequestUploadDto.fromJson(Map<String, Object?> json) =>
      _$RequestUploadDtoFromJson(json);

  final RequestUploadDtoKind kind;

  /// Must be an allowed type for the kind.
  final String mimeType;

  /// Exact size in bytes. The upload URL only accepts this length.
  final num sizeBytes;

  /// PUBLIC for files shown on public profiles; PRIVATE otherwise.
  final RequestUploadDtoVisibility visibility;

  Map<String, Object?> toJson() => _$RequestUploadDtoToJson(this);
}
