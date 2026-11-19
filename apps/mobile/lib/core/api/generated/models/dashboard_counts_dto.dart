// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'dashboard_counts_dto.g.dart';

@JsonSerializable()
class DashboardCountsDto {
  const DashboardCountsDto({
    required this.newMembers7d,
    required this.newMembers30d,
    required this.onboardingCompletionRate30d,
    required this.activeMembers7d,
    required this.activeMembers30d,
    required this.posts7d,
    required this.opportunitiesSaved7d,
    required this.opportunitiesApplied7d,
    required this.courseCompletions30d,
  });
  
  factory DashboardCountsDto.fromJson(Map<String, Object?> json) => _$DashboardCountsDtoFromJson(json);
  
  /// Accounts created in the last 7 days.
  final num newMembers7d;

  /// Accounts created in the last 30 days.
  final num newMembers30d;

  /// Share (0 to 100) of the last 30 days' sign-ups that finished onboarding.
  final num onboardingCompletionRate30d;

  /// Members who signed in during the last 7 days.
  final num activeMembers7d;

  /// Members who signed in during the last 30 days.
  final num activeMembers30d;
  final num posts7d;
  final num opportunitiesSaved7d;
  final num opportunitiesApplied7d;

  /// Courses completed in the last 30 days (0 until Skill Labs is installed).
  final num courseCompletions30d;

  Map<String, Object?> toJson() => _$DashboardCountsDtoToJson(this);
}
