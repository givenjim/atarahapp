// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'consent_dto.dart';
import 'register_dto_client.dart';

part 'register_dto.g.dart';

@JsonSerializable()
class RegisterDto {
  const RegisterDto({
    required this.fullName,
    required this.identifier,
    required this.password,
    required this.consent,
    this.client,
  });

  factory RegisterDto.fromJson(Map<String, Object?> json) =>
      _$RegisterDtoFromJson(json);

  final String fullName;

  /// Email address or phone number (Kenyan local formats are accepted).
  final String identifier;

  /// At least 8 characters including a number.
  final String password;
  final ConsentDto consent;
  final RegisterDtoClient? client;

  Map<String, Object?> toJson() => _$RegisterDtoToJson(this);
}
