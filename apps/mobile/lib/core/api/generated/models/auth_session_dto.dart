// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'me_dto.dart';

part 'auth_session_dto.g.dart';

@JsonSerializable()
class AuthSessionDto {
  const AuthSessionDto({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
    required this.user,
  });

  factory AuthSessionDto.fromJson(Map<String, Object?> json) =>
      _$AuthSessionDtoFromJson(json);

  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
  final DateTime refreshTokenExpiresAt;
  final MeDto user;

  Map<String, Object?> toJson() => _$AuthSessionDtoToJson(this);
}
