// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_overview_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminUserOverviewDto _$AdminUserOverviewDtoFromJson(
  Map<String, dynamic> json,
) => AdminUserOverviewDto(
  user: AdminUserDto.fromJson(json['user'] as Map<String, dynamic>),
  roleGrants: (json['roleGrants'] as List<dynamic>)
      .map((e) => UserRoleGrantDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  statusHistory: (json['statusHistory'] as List<dynamic>)
      .map((e) => StatusHistoryEntryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  sessions: (json['sessions'] as List<dynamic>)
      .map((e) => UserSessionDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  reports: UserReportsDto.fromJson(json['reports'] as Map<String, dynamic>),
  suspendedUntil: json['suspendedUntil'] == null
      ? null
      : DateTime.parse(json['suspendedUntil'] as String),
  profile: json['profile'] == null
      ? null
      : UserProfileSummaryDto.fromJson(json['profile'] as Map<String, dynamic>),
  membership: json['membership'] == null
      ? null
      : UserMembershipDto.fromJson(json['membership'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AdminUserOverviewDtoToJson(
  AdminUserOverviewDto instance,
) => <String, dynamic>{
  'user': instance.user,
  'suspendedUntil': instance.suspendedUntil?.toIso8601String(),
  'profile': instance.profile,
  'roleGrants': instance.roleGrants,
  'membership': instance.membership,
  'statusHistory': instance.statusHistory,
  'sessions': instance.sessions,
  'reports': instance.reports,
};
