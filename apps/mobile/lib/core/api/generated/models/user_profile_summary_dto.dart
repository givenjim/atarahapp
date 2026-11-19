// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'user_profile_summary_dto.g.dart';

@JsonSerializable()
class UserProfileSummaryDto {
  const UserProfileSummaryDto({
    required this.displayName,
    required this.completionPercent,
    required this.onboardingCompleted,
    required this.publishedProjects,
    this.handle,
    this.headline,
    this.county,
    this.discipline,
  });
  
  factory UserProfileSummaryDto.fromJson(Map<String, Object?> json) => _$UserProfileSummaryDtoFromJson(json);
  
  final String? handle;
  final String displayName;
  final String? headline;
  final num completionPercent;
  final bool onboardingCompleted;
  final String? county;
  final String? discipline;
  final num publishedProjects;

  Map<String, Object?> toJson() => _$UserProfileSummaryDtoToJson(this);
}
