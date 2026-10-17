// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'me_dto.dart';

part 'admin_auth_session_dto.g.dart';

@JsonSerializable()
class AdminAuthSessionDto {
  const AdminAuthSessionDto({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
    required this.user,
    this.recoveryCodes,
  });

  factory AdminAuthSessionDto.fromJson(Map<String, Object?> json) =>
      _$AdminAuthSessionDtoFromJson(json);

  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
  final DateTime refreshTokenExpiresAt;
  final MeDto user;

  /// Shown once, on first TOTP enrolment.
  final List<String>? recoveryCodes;

  Map<String, Object?> toJson() => _$AdminAuthSessionDtoToJson(this);
}
