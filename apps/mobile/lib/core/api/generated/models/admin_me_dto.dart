// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_me_dto_roles.dart';
import 'admin_me_dto_status.dart';
import 'membership_summary_dto.dart';

part 'admin_me_dto.g.dart';

@JsonSerializable()
class AdminMeDto {
  const AdminMeDto({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.emailVerified,
    required this.phoneVerified,
    required this.status,
    required this.timeZone,
    required this.locale,
    required this.roles,
    required this.entitlements,
    required this.membership,
    required this.createdAt,
    required this.permissions,
  });

  factory AdminMeDto.fromJson(Map<String, Object?> json) =>
      _$AdminMeDtoFromJson(json);

  final String id;
  final String fullName;
  final String? email;

  /// E.164
  final String? phone;
  final bool emailVerified;
  final bool phoneVerified;
  final AdminMeDtoStatus status;
  final String timeZone;
  final String locale;
  final List<AdminMeDtoRoles> roles;

  /// Hints for showing or hiding controls. The server decides every action.
  final List<String> entitlements;
  final MembershipSummaryDto membership;
  final DateTime createdAt;

  /// Effective permissions, for the console sidebar.
  final List<String> permissions;

  Map<String, Object?> toJson() => _$AdminMeDtoToJson(this);
}
