// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'article_block_dto.dart';
import 'article_dto_source.dart';

part 'article_dto.g.dart';

@JsonSerializable()
class ArticleDto {
  const ArticleDto({
    required this.id,
    required this.slug,
    required this.title,
    required this.summary,
    required this.source,
    required this.authorName,
    required this.readMinutes,
    required this.publishedAt,
    required this.tags,
    required this.blocks,
    required this.saved,
    required this.shareUrl,
    this.sourceLabel,
    this.heroUrl,
  });

  factory ArticleDto.fromJson(Map<String, Object?> json) =>
      _$ArticleDtoFromJson(json);

  final String id;
  final String slug;
  final String title;
  final String summary;
  final ArticleDtoSource source;
  final String? sourceLabel;
  final String authorName;
  final num readMinutes;
  final DateTime publishedAt;
  final String? heroUrl;
  final List<String> tags;
  final List<ArticleBlockDto> blocks;

  /// Whether the signed-in viewer saved it. False when signed out.
  final bool saved;

  /// Public link to share.
  final String shareUrl;

  Map<String, Object?> toJson() => _$ArticleDtoToJson(this);
}
