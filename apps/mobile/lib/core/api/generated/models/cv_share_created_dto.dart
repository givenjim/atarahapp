// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_share_created_dto_status.dart';

part 'cv_share_created_dto.g.dart';

@JsonSerializable()
class CvShareCreatedDto {
  const CvShareCreatedDto({
    required this.id,
    required this.hint,
    required this.createdAt,
    required this.status,
    required this.url,
    this.expiresAt,
    this.revokedAt,
  });
  
  factory CvShareCreatedDto.fromJson(Map<String, Object?> json) => _$CvShareCreatedDtoFromJson(json);
  
  final String id;

  /// Last characters of the token, to tell links apart. The full link is shown only once.
  final String hint;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? revokedAt;
  final CvShareCreatedDtoStatus status;

  /// The public link, `https://atarah.app/{handle}/cv/{token}`. Shown only now.
  final String url;

  Map<String, Object?> toJson() => _$CvShareCreatedDtoToJson(this);
}
