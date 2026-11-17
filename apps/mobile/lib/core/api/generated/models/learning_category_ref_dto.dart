// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'learning_category_group.dart';

part 'learning_category_ref_dto.g.dart';

@JsonSerializable()
class LearningCategoryRefDto {
  const LearningCategoryRefDto({
    required this.id,
    required this.slug,
    required this.name,
    required this.group,
  });

  factory LearningCategoryRefDto.fromJson(Map<String, Object?> json) =>
      _$LearningCategoryRefDtoFromJson(json);

  final String id;
  final String slug;
  final String name;
  final LearningCategoryGroup group;

  Map<String, Object?> toJson() => _$LearningCategoryRefDtoToJson(this);
}
