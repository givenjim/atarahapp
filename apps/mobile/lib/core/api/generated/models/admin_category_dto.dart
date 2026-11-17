// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'learning_category_group.dart';

part 'admin_category_dto.g.dart';

@JsonSerializable()
class AdminCategoryDto {
  const AdminCategoryDto({
    required this.id,
    required this.slug,
    required this.name,
    required this.group,
    required this.sortOrder,
    required this.isActive,
    required this.contentCount,
  });

  factory AdminCategoryDto.fromJson(Map<String, Object?> json) =>
      _$AdminCategoryDtoFromJson(json);

  final String id;
  final String slug;
  final String name;
  final LearningCategoryGroup group;
  final num sortOrder;
  final bool isActive;

  /// All items, whatever their status.
  final num contentCount;

  Map<String, Object?> toJson() => _$AdminCategoryDtoToJson(this);
}
