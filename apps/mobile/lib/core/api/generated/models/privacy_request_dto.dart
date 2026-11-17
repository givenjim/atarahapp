// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'privacy_request_dto_kind.dart';

part 'privacy_request_dto.g.dart';

@JsonSerializable()
class PrivacyRequestDto {
  const PrivacyRequestDto({
    required this.kind,
    required this.id,
    required this.userId,
    required this.status,
    required this.requestedAt,
    this.memberName,
    this.dueAt,
    this.completedAt,
  });

  factory PrivacyRequestDto.fromJson(Map<String, Object?> json) =>
      _$PrivacyRequestDtoFromJson(json);

  final PrivacyRequestDtoKind kind;
  final String id;

  /// The member (a non-personal id; the account may be gone).
  final String userId;

  /// Empty once the account was purged.
  final String? memberName;
  final String status;
  final DateTime requestedAt;

  /// Export link expiry or the purge date.
  final DateTime? dueAt;

  /// When it was finished, cancelled or purged.
  final DateTime? completedAt;

  Map<String, Object?> toJson() => _$PrivacyRequestDtoToJson(this);
}
