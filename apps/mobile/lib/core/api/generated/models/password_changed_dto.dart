// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'password_changed_dto.g.dart';

@JsonSerializable()
class PasswordChangedDto {
  const PasswordChangedDto({required this.sessionsRevoked});

  factory PasswordChangedDto.fromJson(Map<String, Object?> json) =>
      _$PasswordChangedDtoFromJson(json);

  /// Other devices that were signed out.
  final num sessionsRevoked;

  Map<String, Object?> toJson() => _$PasswordChangedDtoToJson(this);
}
