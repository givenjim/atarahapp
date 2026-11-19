// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'error.g.dart';

@JsonSerializable()
class Error {
  const Error({
    required this.code,
    required this.message,
    required this.details,
    required this.requestId,
  });
  
  factory Error.fromJson(Map<String, Object?> json) => _$ErrorFromJson(json);
  
  /// Stable code, e.g. VALIDATION_ERROR, FORBIDDEN, RESOURCE_NOT_FOUND.
  final String code;

  /// Human-readable, safe to show to the user.
  final String message;
  final dynamic details;

  /// Echo of X-Request-Id for support and logs.
  final String requestId;

  Map<String, Object?> toJson() => _$ErrorToJson(this);
}
