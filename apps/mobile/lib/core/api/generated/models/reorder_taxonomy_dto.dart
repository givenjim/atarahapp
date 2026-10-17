// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'reorder_taxonomy_dto.g.dart';

@JsonSerializable()
class ReorderTaxonomyDto {
  const ReorderTaxonomyDto({required this.ids});

  factory ReorderTaxonomyDto.fromJson(Map<String, Object?> json) =>
      _$ReorderTaxonomyDtoFromJson(json);

  /// Ids in the new order. Applies within the same list (discipline) only.
  final List<String> ids;

  Map<String, Object?> toJson() => _$ReorderTaxonomyDtoToJson(this);
}
