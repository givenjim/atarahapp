// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'article_block_dto_type.dart';

part 'article_block_dto.g.dart';

@JsonSerializable()
class ArticleBlockDto {
  const ArticleBlockDto({
    required this.type,
    this.text,
    this.title,
    this.imageUrl,
    this.caption,
    this.attribution,
  });

  factory ArticleBlockDto.fromJson(Map<String, Object?> json) =>
      _$ArticleBlockDtoFromJson(json);

  final ArticleBlockDtoType type;
  final String? text;
  final String? title;

  /// Signed image URL.
  final String? imageUrl;
  final String? caption;
  final String? attribution;

  Map<String, Object?> toJson() => _$ArticleBlockDtoToJson(this);
}
