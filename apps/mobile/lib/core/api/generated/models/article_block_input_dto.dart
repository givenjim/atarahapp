// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'article_block_input_dto_type.dart';

part 'article_block_input_dto.g.dart';

@JsonSerializable()
class ArticleBlockInputDto {
  const ArticleBlockInputDto({
    required this.type,
    this.text,
    this.title,
    this.mediaId,
    this.caption,
    this.attribution,
  });

  factory ArticleBlockInputDto.fromJson(Map<String, Object?> json) =>
      _$ArticleBlockInputDtoFromJson(json);

  final ArticleBlockInputDtoType type;

  /// The words of a paragraph, heading, callout or quote.
  final String? text;

  /// Callout heading, such as "Rule of thumb".
  final String? title;

  /// An image block: a PUBLIC image you uploaded.
  final String? mediaId;
  final String? caption;

  /// Who said it, for a quote.
  final String? attribution;

  Map<String, Object?> toJson() => _$ArticleBlockInputDtoToJson(this);
}
