// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'article_block_input_dto.dart';
import 'update_article_dto_source.dart';

part 'update_article_dto.g.dart';

@JsonSerializable()
class UpdateArticleDto {
  const UpdateArticleDto({
    this.title,
    this.summary,
    this.authorName,
    this.source,
    this.sourceLabel,
    this.heroMediaId,
    this.tags,
    this.blocks,
  });

  factory UpdateArticleDto.fromJson(Map<String, Object?> json) =>
      _$UpdateArticleDtoFromJson(json);

  final String? title;
  final String? summary;
  final String? authorName;
  final UpdateArticleDtoSource? source;

  /// Who it came from. Empty clears it.
  final String? sourceLabel;

  /// A PUBLIC image you uploaded. Send an empty string to remove it.
  final String? heroMediaId;
  final List<String>? tags;
  final List<ArticleBlockInputDto>? blocks;

  Map<String, Object?> toJson() => _$UpdateArticleDtoToJson(this);
}
