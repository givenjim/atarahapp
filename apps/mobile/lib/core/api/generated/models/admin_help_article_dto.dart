// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'help_block_dto.dart';

part 'admin_help_article_dto.g.dart';

@JsonSerializable()
class AdminHelpArticleDto {
  const AdminHelpArticleDto({
    required this.id,
    required this.slug,
    required this.title,
    required this.summary,
    required this.blocks,
    required this.sortOrder,
    required this.published,
    required this.updatedAt,
  });
  
  factory AdminHelpArticleDto.fromJson(Map<String, Object?> json) => _$AdminHelpArticleDtoFromJson(json);
  
  final String id;
  final String slug;
  final String title;
  final String summary;
  final List<HelpBlockDto> blocks;
  final num sortOrder;
  final bool published;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => _$AdminHelpArticleDtoToJson(this);
}
