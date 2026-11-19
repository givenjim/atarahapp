// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'article_block_input_dto.dart';

part 'update_help_article_dto.g.dart';

@JsonSerializable()
class UpdateHelpArticleDto {
  const UpdateHelpArticleDto({
    this.title,
    this.summary,
    this.blocks,
    this.sortOrder,
    this.published,
  });
  
  factory UpdateHelpArticleDto.fromJson(Map<String, Object?> json) => _$UpdateHelpArticleDtoFromJson(json);
  
  final String? title;
  final String? summary;
  final List<ArticleBlockInputDto>? blocks;
  final num? sortOrder;
  final bool? published;

  Map<String, Object?> toJson() => _$UpdateHelpArticleDtoToJson(this);
}
