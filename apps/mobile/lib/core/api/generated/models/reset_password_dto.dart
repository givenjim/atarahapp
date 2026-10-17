// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'reset_password_dto.g.dart';

@JsonSerializable()
class ResetPasswordDto {
  const ResetPasswordDto({
    required this.identifier,
    required this.code,
    required this.newPassword,
  });

  factory ResetPasswordDto.fromJson(Map<String, Object?> json) =>
      _$ResetPasswordDtoFromJson(json);

  /// Email address or phone number (Kenyan local formats are accepted).
  final String identifier;

  /// Six-digit recovery code.
  final String code;
  final String newPassword;

  Map<String, Object?> toJson() => _$ResetPasswordDtoToJson(this);
}
