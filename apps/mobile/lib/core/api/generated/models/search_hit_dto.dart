// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'search_hit_dto_type.dart';

part 'search_hit_dto.g.dart';

@JsonSerializable()
class SearchHitDto {
  const SearchHitDto({
    required this.type,
    required this.id,
    required this.title,
    required this.verified,
    required this.path,
    this.subtitle,
    this.imageUrl,
  });

  factory SearchHitDto.fromJson(Map<String, Object?> json) =>
      _$SearchHitDtoFromJson(json);

  final SearchHitDtoType type;
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;

  /// Verified by Atarah.
  final bool verified;

  /// In-app route that opens it.
  final String path;

  Map<String, Object?> toJson() => _$SearchHitDtoToJson(this);
}
