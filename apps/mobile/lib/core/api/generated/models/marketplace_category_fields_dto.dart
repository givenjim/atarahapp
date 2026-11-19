// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'marketplace_category_fields_dto_tone.dart';

part 'marketplace_category_fields_dto.g.dart';

@JsonSerializable()
class MarketplaceCategoryFieldsDto {
  const MarketplaceCategoryFieldsDto({
    required this.name,
    required this.icon,
    required this.tone,
    this.sortOrder,
    this.isActive,
  });
  
  factory MarketplaceCategoryFieldsDto.fromJson(Map<String, Object?> json) => _$MarketplaceCategoryFieldsDtoFromJson(json);
  
  final String name;

  /// Lucide icon name.
  final String icon;
  final MarketplaceCategoryFieldsDtoTone tone;
  final num? sortOrder;
  final bool? isActive;

  Map<String, Object?> toJson() => _$MarketplaceCategoryFieldsDtoToJson(this);
}
