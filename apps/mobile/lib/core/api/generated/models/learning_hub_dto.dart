// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'continue_learning_dto.dart';
import 'hub_category_dto.dart';
import 'learning_card_dto.dart';
import 'recommended_dto.dart';

part 'learning_hub_dto.g.dart';

@JsonSerializable()
class LearningHubDto {
  const LearningHubDto({
    required this.featured,
    required this.categories,
    required this.recommended,
    this.continueLearning,
  });

  factory LearningHubDto.fromJson(Map<String, Object?> json) =>
      _$LearningHubDtoFromJson(json);

  final ContinueLearningDto? continueLearning;
  final List<LearningCardDto> featured;
  final List<HubCategoryDto> categories;
  final List<RecommendedDto> recommended;

  Map<String, Object?> toJson() => _$LearningHubDtoToJson(this);
}
