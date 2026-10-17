// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'update_taxonomy_item_dto.g.dart';

@JsonSerializable()
class UpdateTaxonomyItemDto {
  const UpdateTaxonomyItemDto({this.name, this.icon, this.isActive});

  factory UpdateTaxonomyItemDto.fromJson(Map<String, Object?> json) =>
      _$UpdateTaxonomyItemDtoFromJson(json);

  final String? name;
  final String? icon;

  /// false archives the entry (hidden from new selections, kept on existing profiles).
  final bool? isActive;

  Map<String, Object?> toJson() => _$UpdateTaxonomyItemDtoToJson(this);
}
