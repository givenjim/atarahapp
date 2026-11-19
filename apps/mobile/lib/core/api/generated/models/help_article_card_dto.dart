// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'help_article_card_dto.g.dart';

@JsonSerializable()
class HelpArticleCardDto {
  const HelpArticleCardDto({
    required this.id,
    required this.slug,
    required this.title,
    required this.summary,
  });
  
  factory HelpArticleCardDto.fromJson(Map<String, Object?> json) => _$HelpArticleCardDtoFromJson(json);
  
  final String id;
  final String slug;
  final String title;
  final String summary;

  Map<String, Object?> toJson() => _$HelpArticleCardDtoToJson(this);
}
