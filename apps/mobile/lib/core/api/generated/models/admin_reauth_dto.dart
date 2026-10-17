// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'admin_reauth_dto.g.dart';

@JsonSerializable()
class AdminReauthDto {
  const AdminReauthDto({required this.password, required this.code});

  factory AdminReauthDto.fromJson(Map<String, Object?> json) =>
      _$AdminReauthDtoFromJson(json);

  final String password;
  final String code;

  Map<String, Object?> toJson() => _$AdminReauthDtoToJson(this);
}
