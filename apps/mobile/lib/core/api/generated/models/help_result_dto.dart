// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'faq_dto.dart';
import 'help_article_card_dto.dart';

part 'help_result_dto.g.dart';

@JsonSerializable()
class HelpResultDto {
  const HelpResultDto({required this.articles, required this.faq});

  factory HelpResultDto.fromJson(Map<String, Object?> json) =>
      _$HelpResultDtoFromJson(json);

  final List<HelpArticleCardDto> articles;
  final List<FaqDto> faq;

  Map<String, Object?> toJson() => _$HelpResultDtoToJson(this);
}
