// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cv_share_dto_status.dart';

part 'cv_share_dto.g.dart';

@JsonSerializable()
class CvShareDto {
  const CvShareDto({
    required this.id,
    required this.hint,
    required this.createdAt,
    required this.status,
    this.expiresAt,
    this.revokedAt,
  });
  
  factory CvShareDto.fromJson(Map<String, Object?> json) => _$CvShareDtoFromJson(json);
  
  final String id;

  /// Last characters of the token, to tell links apart. The full link is shown only once.
  final String hint;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? revokedAt;
  final CvShareDtoStatus status;

  Map<String, Object?> toJson() => _$CvShareDtoToJson(this);
}
