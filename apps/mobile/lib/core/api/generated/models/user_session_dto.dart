// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'user_session_dto.g.dart';

@JsonSerializable()
class UserSessionDto {
  const UserSessionDto({
    required this.id,
    required this.client,
    required this.lastActiveAt,
    this.deviceName,
  });

  factory UserSessionDto.fromJson(Map<String, Object?> json) =>
      _$UserSessionDtoFromJson(json);

  final String id;
  final String client;
  final String? deviceName;
  final DateTime lastActiveAt;

  Map<String, Object?> toJson() => _$UserSessionDtoToJson(this);
}
