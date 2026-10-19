// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'article_card_dto.dart';

part 'saved_article_dto.g.dart';

@JsonSerializable()
class SavedArticleDto {
  const SavedArticleDto({required this.savedAt, required this.article});

  factory SavedArticleDto.fromJson(Map<String, Object?> json) =>
      _$SavedArticleDtoFromJson(json);

  final DateTime savedAt;
  final ArticleCardDto article;

  Map<String, Object?> toJson() => _$SavedArticleDtoToJson(this);
}
