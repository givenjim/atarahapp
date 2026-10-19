// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'search_group_dto_type.dart';
import 'search_hit_dto.dart';

part 'search_group_dto.g.dart';

@JsonSerializable()
class SearchGroupDto {
  const SearchGroupDto({
    required this.type,
    required this.count,
    required this.items,
  });

  factory SearchGroupDto.fromJson(Map<String, Object?> json) =>
      _$SearchGroupDtoFromJson(json);

  final SearchGroupDtoType type;

  /// How many results there are in all.
  final num count;
  final List<SearchHitDto> items;

  Map<String, Object?> toJson() => _$SearchGroupDtoToJson(this);
}
