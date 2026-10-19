// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_article_list_item_dto_source.dart';
import 'admin_article_list_item_dto_status.dart';

part 'admin_article_list_item_dto.g.dart';

@JsonSerializable()
class AdminArticleListItemDto {
  const AdminArticleListItemDto({
    required this.id,
    required this.slug,
    required this.title,
    required this.authorName,
    required this.status,
    required this.source,
    required this.scheduled,
    required this.featured,
    required this.updatedAt,
    this.publishedAt,
  });

  factory AdminArticleListItemDto.fromJson(Map<String, Object?> json) =>
      _$AdminArticleListItemDtoFromJson(json);

  final String id;
  final String slug;
  final String title;
  final String authorName;
  final AdminArticleListItemDtoStatus status;
  final AdminArticleListItemDtoSource source;
  final DateTime? publishedAt;

  /// Published with a time that has not come yet.
  final bool scheduled;

  /// Pinned on Home.
  final bool featured;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => _$AdminArticleListItemDtoToJson(this);
}
