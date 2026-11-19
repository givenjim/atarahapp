// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'update_marketplace_category_dto_tone.dart';

part 'update_marketplace_category_dto.g.dart';

@JsonSerializable()
class UpdateMarketplaceCategoryDto {
  const UpdateMarketplaceCategoryDto({
    this.name,
    this.icon,
    this.tone,
    this.sortOrder,
    this.isActive,
  });
  
  factory UpdateMarketplaceCategoryDto.fromJson(Map<String, Object?> json) => _$UpdateMarketplaceCategoryDtoFromJson(json);
  
  final String? name;
  final String? icon;
  final UpdateMarketplaceCategoryDtoTone? tone;
  final num? sortOrder;
  final bool? isActive;

  Map<String, Object?> toJson() => _$UpdateMarketplaceCategoryDtoToJson(this);
}
