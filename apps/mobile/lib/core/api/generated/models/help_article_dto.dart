// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'help_block_dto.dart';

part 'help_article_dto.g.dart';

@JsonSerializable()
class HelpArticleDto {
  const HelpArticleDto({
    required this.id,
    required this.slug,
    required this.title,
    required this.summary,
    required this.blocks,
  });
  
  factory HelpArticleDto.fromJson(Map<String, Object?> json) => _$HelpArticleDtoFromJson(json);
  
  final String id;
  final String slug;
  final String title;
  final String summary;
  final List<HelpBlockDto> blocks;

  Map<String, Object?> toJson() => _$HelpArticleDtoToJson(this);
}
