// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'sessions_revoked_dto.g.dart';

@JsonSerializable()
class SessionsRevokedDto {
  const SessionsRevokedDto({required this.sessionsRevoked});

  factory SessionsRevokedDto.fromJson(Map<String, Object?> json) =>
      _$SessionsRevokedDtoFromJson(json);

  final num sessionsRevoked;

  Map<String, Object?> toJson() => _$SessionsRevokedDtoToJson(this);
}
