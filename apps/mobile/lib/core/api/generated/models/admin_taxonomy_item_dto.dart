// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'admin_taxonomy_item_dto.g.dart';

@JsonSerializable()
class AdminTaxonomyItemDto {
  const AdminTaxonomyItemDto({
    required this.id,
    required this.slug,
    required this.name,
    required this.icon,
    required this.disciplineId,
    required this.disciplineName,
    required this.sortOrder,
    required this.isActive,
    required this.usage,
  });

  factory AdminTaxonomyItemDto.fromJson(Map<String, Object?> json) =>
      _$AdminTaxonomyItemDtoFromJson(json);

  final String id;
  final String slug;
  final String name;

  /// Disciplines only.
  final String? icon;

  /// Specialisations and skills.
  final String? disciplineId;
  final String? disciplineName;
  final num sortOrder;
  final bool isActive;

  /// How many members currently use it.
  final num usage;

  Map<String, Object?> toJson() => _$AdminTaxonomyItemDtoToJson(this);
}
