// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'article_card_dto_source.dart';

part 'article_card_dto.g.dart';

@JsonSerializable()
class ArticleCardDto {
  const ArticleCardDto({
    required this.id,
    required this.slug,
    required this.title,
    required this.summary,
    required this.source,
    required this.authorName,
    required this.readMinutes,
    required this.publishedAt,
    required this.tags,
    this.sourceLabel,
    this.heroUrl,
  });

  factory ArticleCardDto.fromJson(Map<String, Object?> json) =>
      _$ArticleCardDtoFromJson(json);

  final String id;
  final String slug;
  final String title;
  final String summary;
  final ArticleCardDtoSource source;
  final String? sourceLabel;
  final String authorName;
  final num readMinutes;
  final DateTime publishedAt;
  final String? heroUrl;
  final List<String> tags;

  Map<String, Object?> toJson() => _$ArticleCardDtoToJson(this);
}
