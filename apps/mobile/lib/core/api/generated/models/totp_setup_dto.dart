// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'totp_setup_dto.g.dart';

@JsonSerializable()
class TotpSetupDto {
  const TotpSetupDto({required this.secret, required this.otpauthUrl});

  factory TotpSetupDto.fromJson(Map<String, Object?> json) =>
      _$TotpSetupDtoFromJson(json);

  /// Base32 secret. Shown once.
  final String secret;

  /// otpauth:// URL for QR codes.
  final String otpauthUrl;

  Map<String, Object?> toJson() => _$TotpSetupDtoToJson(this);
}
