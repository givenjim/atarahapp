// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'content_delivery.dart';
import 'content_source.dart';
import 'course_info_dto.dart';
import 'learning_access.dart';
import 'learning_category_ref_dto.dart';
import 'learning_content_type.dart';
import 'learning_detail_dto_link_status.dart';
import 'learning_item_progress_dto.dart';
import 'skill_level.dart';
import 'skill_ref_dto.dart';

part 'learning_detail_dto.g.dart';

@JsonSerializable()
class LearningDetailDto {
  const LearningDetailDto({
    required this.id,
    required this.slug,
    required this.type,
    required this.title,
    required this.summary,
    required this.category,
    required this.level,
    required this.durationMinutes,
    required this.source,
    required this.delivery,
    required this.access,
    required this.premiumLocked,
    required this.featured,
    required this.saved,
    required this.whatYouLearn,
    required this.disciplines,
    required this.skills,
    required this.linkStatus,
    required this.shareUrl,
    this.lessonCount,
    this.providerName,
    this.coverUrl,
    this.progress,
    this.whoItsFor,
    this.instructorName,
    this.course,
    this.externalUrl,
    this.externalDomain,
    this.embedUrl,
    this.itemProgress,
  });
  
  factory LearningDetailDto.fromJson(Map<String, Object?> json) => _$LearningDetailDtoFromJson(json);
  
  final String id;
  final String slug;
  final LearningContentType type;
  final String title;
  final String summary;
  final LearningCategoryRefDto category;
  final SkillLevel level;
  final num durationMinutes;
  final num? lessonCount;
  final ContentSource source;
  final ContentDelivery delivery;
  final String? providerName;
  final String? coverUrl;
  final LearningAccess access;

  /// Premium content the caller cannot open yet (show AtPremiumGate).
  final bool premiumLocked;
  final bool featured;
  final bool saved;
  final LearningItemProgressDto? progress;
  final List<String> whatYouLearn;
  final String? whoItsFor;
  final String? instructorName;

  /// Discipline names.
  final List<String> disciplines;
  final List<SkillRefDto> skills;
  final CourseInfoDto? course;

  /// EXTERNAL_LINK content: where it opens.
  final String? externalUrl;

  /// The domain named in the leaving-Atarah sheet.
  final String? externalDomain;

  /// EMBEDDED single items: the player address.
  final String? embedUrl;

  /// BROKEN: show "This link no longer works".
  final LearningDetailDtoLinkStatus linkStatus;

  /// Non-course items: started or completed.
  final LearningItemProgressDto? itemProgress;
  final String shareUrl;

  Map<String, Object?> toJson() => _$LearningDetailDtoToJson(this);
}
