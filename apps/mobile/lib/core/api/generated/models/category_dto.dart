// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'category_dto.g.dart';

@JsonSerializable()
class CategoryDto {
  const CategoryDto({
    required this.id,
    required this.slug,
    required this.name,
    required this.icon,
    required this.tone,
    required this.count,
  });
  
  factory CategoryDto.fromJson(Map<String, Object?> json) => _$CategoryDtoFromJson(json);
  
  final String id;
  final String slug;
  final String name;

  /// Lucide icon name.
  final String icon;

  /// Design-token tone.
  final String tone;

  /// Published listings in this category.
  final num count;

  Map<String, Object?> toJson() => _$CategoryDtoToJson(this);
}
