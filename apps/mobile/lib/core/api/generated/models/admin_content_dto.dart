// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_content_dto_link_status.dart';
import 'admin_lesson_dto.dart';
import 'content_delivery.dart';
import 'content_source.dart';
import 'learning_access.dart';
import 'learning_category_ref_dto.dart';
import 'learning_content_type.dart';
import 'publication_status.dart';
import 'skill_level.dart';

part 'admin_content_dto.g.dart';

@JsonSerializable()
class AdminContentDto {
  const AdminContentDto({
    required this.id,
    required this.slug,
    required this.title,
    required this.type,
    required this.summary,
    required this.category,
    required this.level,
    required this.durationMinutes,
    required this.source,
    required this.delivery,
    required this.access,
    required this.status,
    required this.featured,
    required this.whatYouLearn,
    required this.disciplineIds,
    required this.skillIds,
    required this.linkStatus,
    required this.lessons,
    required this.enrolmentCount,
    required this.createdAt,
    required this.updatedAt,
    this.providerName,
    this.instructorUserId,
    this.externalUrl,
    this.embedUrl,
    this.coverMediaId,
    this.coverUrl,
    this.publishedAt,
    this.whoItsFor,
    this.lastCheckedAt,
    this.sequential,
  });
  
  factory AdminContentDto.fromJson(Map<String, Object?> json) => _$AdminContentDtoFromJson(json);
  
  final String id;
  final String slug;
  final String title;
  final LearningContentType type;
  final String summary;
  final LearningCategoryRefDto category;
  final SkillLevel level;
  final num durationMinutes;
  final ContentSource source;
  final ContentDelivery delivery;
  final String? providerName;
  final String? instructorUserId;
  final String? externalUrl;
  final String? embedUrl;
  final String? coverMediaId;
  final String? coverUrl;
  final LearningAccess access;
  final PublicationStatus status;
  final DateTime? publishedAt;
  final bool featured;
  final List<String> whatYouLearn;
  final String? whoItsFor;
  final List<String> disciplineIds;
  final List<String> skillIds;
  final AdminContentDtoLinkStatus linkStatus;
  final DateTime? lastCheckedAt;
  final bool? sequential;
  final List<AdminLessonDto> lessons;
  final num enrolmentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => _$AdminContentDtoToJson(this);
}
