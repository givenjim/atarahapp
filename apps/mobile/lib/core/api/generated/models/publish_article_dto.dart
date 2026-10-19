// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'publish_article_dto.g.dart';

@JsonSerializable()
class PublishArticleDto {
  const PublishArticleDto({this.publishAt});

  factory PublishArticleDto.fromJson(Map<String, Object?> json) =>
      _$PublishArticleDtoFromJson(json);

  /// Go live at this time. Leave out to publish now.
  final DateTime? publishAt;

  Map<String, Object?> toJson() => _$PublishArticleDtoToJson(this);
}
