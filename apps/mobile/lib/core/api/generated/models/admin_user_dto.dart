// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_user_dto_status.dart';

part 'admin_user_dto.g.dart';

@JsonSerializable()
class AdminUserDto {
  const AdminUserDto({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.status,
    required this.statusReason,
    required this.roles,
    required this.lastLoginAt,
    required this.createdAt,
  });

  factory AdminUserDto.fromJson(Map<String, Object?> json) =>
      _$AdminUserDtoFromJson(json);

  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final AdminUserDtoStatus status;
  final String? statusReason;
  final List<String> roles;
  final DateTime? lastLoginAt;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$AdminUserDtoToJson(this);
}
