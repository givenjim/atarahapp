// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'create_article_dto.g.dart';

@JsonSerializable()
class CreateArticleDto {
  const CreateArticleDto({required this.title, required this.authorName});

  factory CreateArticleDto.fromJson(Map<String, Object?> json) =>
      _$CreateArticleDtoFromJson(json);

  final String title;

  /// The byline.
  final String authorName;

  Map<String, Object?> toJson() => _$CreateArticleDtoToJson(this);
}
