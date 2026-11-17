// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_user_dto.dart';
import 'status_history_entry_dto.dart';
import 'user_membership_dto.dart';
import 'user_profile_summary_dto.dart';
import 'user_reports_dto.dart';
import 'user_role_grant_dto.dart';
import 'user_session_dto.dart';

part 'admin_user_overview_dto.g.dart';

@JsonSerializable()
class AdminUserOverviewDto {
  const AdminUserOverviewDto({
    required this.user,
    required this.roleGrants,
    required this.statusHistory,
    required this.sessions,
    required this.reports,
    this.suspendedUntil,
    this.profile,
    this.membership,
  });

  factory AdminUserOverviewDto.fromJson(Map<String, Object?> json) =>
      _$AdminUserOverviewDtoFromJson(json);

  final AdminUserDto user;

  /// A temporary suspension ends here.
  final DateTime? suspendedUntil;
  final UserProfileSummaryDto? profile;
  final List<UserRoleGrantDto> roleGrants;
  final UserMembershipDto? membership;
  final List<StatusHistoryEntryDto> statusHistory;
  final List<UserSessionDto> sessions;
  final UserReportsDto reports;

  Map<String, Object?> toJson() => _$AdminUserOverviewDtoToJson(this);
}
