// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileSummaryDto _$UserProfileSummaryDtoFromJson(
  Map<String, dynamic> json,
) => UserProfileSummaryDto(
  displayName: json['displayName'] as String,
  completionPercent: json['completionPercent'] as num,
  onboardingCompleted: json['onboardingCompleted'] as bool,
  publishedProjects: json['publishedProjects'] as num,
  handle: json['handle'] as String?,
  headline: json['headline'] as String?,
  county: json['county'] as String?,
  discipline: json['discipline'] as String?,
);

Map<String, dynamic> _$UserProfileSummaryDtoToJson(
  UserProfileSummaryDto instance,
) => <String, dynamic>{
  'handle': instance.handle,
  'displayName': instance.displayName,
  'headline': instance.headline,
  'completionPercent': instance.completionPercent,
  'onboardingCompleted': instance.onboardingCompleted,
  'county': instance.county,
  'discipline': instance.discipline,
  'publishedProjects': instance.publishedProjects,
};
