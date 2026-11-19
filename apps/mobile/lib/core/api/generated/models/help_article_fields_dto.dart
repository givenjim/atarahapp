// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'article_block_input_dto.dart';

part 'help_article_fields_dto.g.dart';

@JsonSerializable()
class HelpArticleFieldsDto {
  const HelpArticleFieldsDto({
    required this.slug,
    required this.title,
    this.summary,
    this.blocks,
    this.sortOrder,
    this.published,
  });
  
  factory HelpArticleFieldsDto.fromJson(Map<String, Object?> json) => _$HelpArticleFieldsDtoFromJson(json);
  
  /// Lower-case words and dashes. Never changed after publishing.
  final String slug;
  final String title;
  final String? summary;

  /// Paragraph, heading, callout and quote blocks.
  final List<ArticleBlockInputDto>? blocks;
  final num? sortOrder;
  final bool? published;

  Map<String, Object?> toJson() => _$HelpArticleFieldsDtoToJson(this);
}
