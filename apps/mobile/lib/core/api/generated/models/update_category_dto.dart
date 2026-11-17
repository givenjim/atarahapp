// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'learning_category_group.dart';

part 'update_category_dto.g.dart';

@JsonSerializable()
class UpdateCategoryDto {
  const UpdateCategoryDto({
    required this.name,
    required this.group,
    required this.sortOrder,
    required this.isActive,
  });

  factory UpdateCategoryDto.fromJson(Map<String, Object?> json) =>
      _$UpdateCategoryDtoFromJson(json);

  final String name;
  final LearningCategoryGroup group;
  final num sortOrder;
  final bool isActive;

  Map<String, Object?> toJson() => _$UpdateCategoryDtoToJson(this);
}
