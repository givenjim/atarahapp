// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'create_taxonomy_item_dto.g.dart';

@JsonSerializable()
class CreateTaxonomyItemDto {
  const CreateTaxonomyItemDto({
    required this.name,
    this.icon,
    this.disciplineId,
  });

  factory CreateTaxonomyItemDto.fromJson(Map<String, Object?> json) =>
      _$CreateTaxonomyItemDtoFromJson(json);

  final String name;

  /// Disciplines only: a Lucide icon name.
  final String? icon;

  /// Required for specialisations; optional for skills (blank = general).
  final String? disciplineId;

  Map<String, Object?> toJson() => _$CreateTaxonomyItemDtoToJson(this);
}
