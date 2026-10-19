// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_article_block_dto.dart';
import 'admin_article_dto_source.dart';
import 'admin_article_dto_status.dart';

part 'admin_article_dto.g.dart';

@JsonSerializable()
class AdminArticleDto {
  const AdminArticleDto({
    required this.id,
    required this.slug,
    required this.title,
    required this.authorName,
    required this.status,
    required this.source,
    required this.scheduled,
    required this.featured,
    required this.updatedAt,
    required this.summary,
    required this.readMinutes,
    required this.tags,
    required this.blocks,
    required this.createdAt,
    this.publishedAt,
    this.sourceLabel,
    this.heroMediaId,
    this.heroUrl,
  });

  factory AdminArticleDto.fromJson(Map<String, Object?> json) =>
      _$AdminArticleDtoFromJson(json);

  final String id;
  final String slug;
  final String title;
  final String authorName;
  final AdminArticleDtoStatus status;
  final AdminArticleDtoSource source;
  final DateTime? publishedAt;

  /// Published with a time that has not come yet.
  final bool scheduled;

  /// Pinned on Home.
  final bool featured;
  final DateTime updatedAt;
  final String summary;
  final String? sourceLabel;
  final num readMinutes;
  final List<String> tags;
  final String? heroMediaId;
  final String? heroUrl;
  final List<AdminArticleBlockDto> blocks;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$AdminArticleDtoToJson(this);
}
