// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_article_block_dto_type.dart';

part 'admin_article_block_dto.g.dart';

@JsonSerializable()
class AdminArticleBlockDto {
  const AdminArticleBlockDto({
    required this.type,
    this.text,
    this.title,
    this.imageUrl,
    this.caption,
    this.attribution,
    this.mediaId,
  });

  factory AdminArticleBlockDto.fromJson(Map<String, Object?> json) =>
      _$AdminArticleBlockDtoFromJson(json);

  final AdminArticleBlockDtoType type;
  final String? text;
  final String? title;

  /// Signed image URL.
  final String? imageUrl;
  final String? caption;
  final String? attribution;
  final String? mediaId;

  Map<String, Object?> toJson() => _$AdminArticleBlockDtoToJson(this);
}
