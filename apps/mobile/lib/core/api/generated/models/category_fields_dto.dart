// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'learning_category_group.dart';

part 'category_fields_dto.g.dart';

@JsonSerializable()
class CategoryFieldsDto {
  const CategoryFieldsDto({
    required this.name,
    required this.group,
    this.sortOrder,
    this.isActive,
  });

  factory CategoryFieldsDto.fromJson(Map<String, Object?> json) =>
      _$CategoryFieldsDtoFromJson(json);

  final String name;
  final LearningCategoryGroup group;
  final num? sortOrder;
  final bool? isActive;

  Map<String, Object?> toJson() => _$CategoryFieldsDtoToJson(this);
}
