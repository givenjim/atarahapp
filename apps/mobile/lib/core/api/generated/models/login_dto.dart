// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'login_dto_client.dart';

part 'login_dto.g.dart';

@JsonSerializable()
class LoginDto {
  const LoginDto({
    required this.identifier,
    required this.password,
    required this.client,
    this.deviceName,
  });

  factory LoginDto.fromJson(Map<String, Object?> json) =>
      _$LoginDtoFromJson(json);

  /// Email address or phone number (Kenyan local formats are accepted).
  final String identifier;
  final String password;
  final LoginDtoClient client;

  /// Shown in Settings > Security > Active sessions.
  final String? deviceName;

  Map<String, Object?> toJson() => _$LoginDtoToJson(this);
}
