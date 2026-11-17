// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'content_delivery.dart';
import 'content_source.dart';
import 'learning_access.dart';
import 'learning_category_ref_dto.dart';
import 'learning_content_type.dart';
import 'learning_item_progress_dto.dart';
import 'skill_level.dart';

part 'learning_card_dto.g.dart';

@JsonSerializable()
class LearningCardDto {
  const LearningCardDto({
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
    this.lessonCount,
    this.providerName,
    this.coverUrl,
    this.progress,
  });

  factory LearningCardDto.fromJson(Map<String, Object?> json) =>
      _$LearningCardDtoFromJson(json);

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

  Map<String, Object?> toJson() => _$LearningCardDtoToJson(this);
}
