// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'content_delivery.dart';
import 'content_source.dart';
import 'learning_access.dart';
import 'learning_content_type.dart';
import 'skill_level.dart';

part 'update_content_dto.g.dart';

@JsonSerializable()
class UpdateContentDto {
  const UpdateContentDto({
    required this.title,
    required this.type,
    required this.summary,
    required this.categoryId,
    required this.level,
    required this.durationMinutes,
    required this.source,
    required this.delivery,
    required this.providerName,
    required this.instructorUserId,
    required this.externalUrl,
    required this.embedUrl,
    required this.coverMediaId,
    required this.access,
    required this.featured,
    required this.whatYouLearn,
    required this.whoItsFor,
    required this.disciplineIds,
    required this.skillIds,
    required this.sequential,
  });

  factory UpdateContentDto.fromJson(Map<String, Object?> json) =>
      _$UpdateContentDtoFromJson(json);

  final String title;
  final LearningContentType type;
  final String summary;
  final String categoryId;
  final SkillLevel level;
  final num durationMinutes;
  final ContentSource source;
  final ContentDelivery delivery;
  final String? providerName;
  final String? instructorUserId;
  final String? externalUrl;
  final String? embedUrl;
  final String? coverMediaId;
  final LearningAccess access;
  final bool featured;
  final List<String> whatYouLearn;
  final String? whoItsFor;
  final List<String> disciplineIds;
  final List<String> skillIds;
  final bool sequential;

  Map<String, Object?> toJson() => _$UpdateContentDtoToJson(this);
}
