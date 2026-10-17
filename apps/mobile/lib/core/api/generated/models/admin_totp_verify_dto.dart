// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'admin_totp_verify_dto.g.dart';

@JsonSerializable()
class AdminTotpVerifyDto {
  const AdminTotpVerifyDto({
    required this.challengeToken,
    this.code,
    this.recoveryCode,
  });

  factory AdminTotpVerifyDto.fromJson(Map<String, Object?> json) =>
      _$AdminTotpVerifyDtoFromJson(json);

  /// Short-lived token returned by POST /admin/auth/login.
  final String challengeToken;

  /// Authenticator code. Omit when using a recovery code.
  final String? code;

  /// One-time recovery code (XXXX-XXXX-XXXX).
  final String? recoveryCode;

  Map<String, Object?> toJson() => _$AdminTotpVerifyDtoToJson(this);
}
