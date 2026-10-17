// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'verify_dto_client.dart';

part 'verify_dto.g.dart';

@JsonSerializable()
class VerifyDto {
  const VerifyDto({
    required this.identifier,
    required this.code,
    this.client,
    this.deviceName,
  });

  factory VerifyDto.fromJson(Map<String, Object?> json) =>
      _$VerifyDtoFromJson(json);

  /// Email address or phone number (Kenyan local formats are accepted).
  final String identifier;

  /// Six-digit one-time code.
  final String code;
  final VerifyDtoClient? client;
  final String? deviceName;

  Map<String, Object?> toJson() => _$VerifyDtoToJson(this);
}
