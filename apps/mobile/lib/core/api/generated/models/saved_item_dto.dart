// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'article_card_dto.dart';
import 'saved_kind.dart';

part 'saved_item_dto.g.dart';

@JsonSerializable()
class SavedItemDto {
  const SavedItemDto({
    required this.type,
    required this.targetId,
    required this.savedAt,
    required this.title,
    required this.path,
    this.collection,
    this.subtitle,
    this.imageUrl,
    this.article,
  });

  factory SavedItemDto.fromJson(Map<String, Object?> json) =>
      _$SavedItemDtoFromJson(json);

  final SavedKind type;

  /// Id of the saved thing (a creative is saved by profile id).
  final String targetId;
  final DateTime savedAt;
  final String? collection;
  final String title;
  final String? subtitle;
  final String? imageUrl;

  /// The in-app path that opens it.
  final String path;

  /// Present for ARTICLE rows.
  final ArticleCardDto? article;

  Map<String, Object?> toJson() => _$SavedItemDtoToJson(this);
}
