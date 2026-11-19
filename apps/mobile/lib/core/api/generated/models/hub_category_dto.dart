// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'learning_category_group.dart';

part 'hub_category_dto.g.dart';

@JsonSerializable()
class HubCategoryDto {
  const HubCategoryDto({
    required this.id,
    required this.slug,
    required this.name,
    required this.group,
    required this.count,
  });
  
  factory HubCategoryDto.fromJson(Map<String, Object?> json) => _$HubCategoryDtoFromJson(json);
  
  final String id;
  final String slug;
  final String name;
  final LearningCategoryGroup group;

  /// Published items in this category.
  final num count;

  Map<String, Object?> toJson() => _$HubCategoryDtoToJson(this);
}
