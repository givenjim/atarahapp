// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'content_delivery.dart';
import 'content_source.dart';
import 'learning_access.dart';
import 'learning_content_type.dart';
import 'skill_level.dart';

part 'content_fields_dto.g.dart';

@JsonSerializable()
class ContentFieldsDto {
  const ContentFieldsDto({
    required this.title,
    required this.type,
    required this.summary,
    required this.categoryId,
    this.level,
    this.durationMinutes,
    this.source,
    this.delivery,
    this.providerName,
    this.instructorUserId,
    this.externalUrl,
    this.embedUrl,
    this.coverMediaId,
    this.access,
    this.featured,
    this.whatYouLearn,
    this.whoItsFor,
    this.disciplineIds,
    this.skillIds,
    this.sequential,
  });
  
  factory ContentFieldsDto.fromJson(Map<String, Object?> json) => _$ContentFieldsDtoFromJson(json);
  
  final String title;
  final LearningContentType type;
  final String summary;
  final String categoryId;
  final SkillLevel? level;

  /// Items that are not courses. A course takes its lessons’ total.
  final num? durationMinutes;
  final ContentSource? source;
  final ContentDelivery? delivery;
  final String? providerName;

  /// The instructor’s member account.
  final String? instructorUserId;

  /// Required for EXTERNAL_LINK. https only.
  final String? externalUrl;

  /// Single embedded items. Host must be on the allow-list.
  final String? embedUrl;

  /// A READY public image.
  final String? coverMediaId;
  final LearningAccess? access;
  final bool? featured;
  final List<String>? whatYouLearn;
  final String? whoItsFor;
  final List<String>? disciplineIds;
  final List<String>? skillIds;

  /// Courses only.
  final bool? sequential;

  Map<String, Object?> toJson() => _$ContentFieldsDtoToJson(this);
}
