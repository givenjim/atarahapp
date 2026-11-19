// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'admin_marketplace_category_dto.g.dart';

@JsonSerializable()
class AdminMarketplaceCategoryDto {
  const AdminMarketplaceCategoryDto({
    required this.id,
    required this.slug,
    required this.name,
    required this.icon,
    required this.tone,
    required this.count,
    required this.sortOrder,
    required this.isActive,
  });
  
  factory AdminMarketplaceCategoryDto.fromJson(Map<String, Object?> json) => _$AdminMarketplaceCategoryDtoFromJson(json);
  
  final String id;
  final String slug;
  final String name;

  /// Lucide icon name.
  final String icon;

  /// Design-token tone.
  final String tone;

  /// Published listings in this category.
  final num count;
  final num sortOrder;
  final bool isActive;

  Map<String, Object?> toJson() => _$AdminMarketplaceCategoryDtoToJson(this);
}
