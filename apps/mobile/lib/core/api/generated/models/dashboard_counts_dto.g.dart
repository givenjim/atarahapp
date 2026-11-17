// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_counts_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardCountsDto _$DashboardCountsDtoFromJson(Map<String, dynamic> json) =>
    DashboardCountsDto(
      newMembers7d: json['newMembers7d'] as num,
      newMembers30d: json['newMembers30d'] as num,
      onboardingCompletionRate30d: json['onboardingCompletionRate30d'] as num,
      activeMembers7d: json['activeMembers7d'] as num,
      activeMembers30d: json['activeMembers30d'] as num,
      posts7d: json['posts7d'] as num,
      opportunitiesSaved7d: json['opportunitiesSaved7d'] as num,
      opportunitiesApplied7d: json['opportunitiesApplied7d'] as num,
      courseCompletions30d: json['courseCompletions30d'] as num,
    );

Map<String, dynamic> _$DashboardCountsDtoToJson(DashboardCountsDto instance) =>
    <String, dynamic>{
      'newMembers7d': instance.newMembers7d,
      'newMembers30d': instance.newMembers30d,
      'onboardingCompletionRate30d': instance.onboardingCompletionRate30d,
      'activeMembers7d': instance.activeMembers7d,
      'activeMembers30d': instance.activeMembers30d,
      'posts7d': instance.posts7d,
      'opportunitiesSaved7d': instance.opportunitiesSaved7d,
      'opportunitiesApplied7d': instance.opportunitiesApplied7d,
      'courseCompletions30d': instance.courseCompletions30d,
    };
