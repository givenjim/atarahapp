// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'taxonomy_item_dto.g.dart';

@JsonSerializable()
class TaxonomyItemDto {
  const TaxonomyItemDto({
    required this.id,
    required this.slug,
    required this.name,
  });

  factory TaxonomyItemDto.fromJson(Map<String, Object?> json) =>
      _$TaxonomyItemDtoFromJson(json);

  final String id;
  final String slug;
  final String name;

  Map<String, Object?> toJson() => _$TaxonomyItemDtoToJson(this);
}
