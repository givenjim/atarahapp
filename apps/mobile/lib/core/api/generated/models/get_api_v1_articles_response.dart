// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'article_card_dto.dart';

part 'get_api_v1_articles_response.g.dart';

@JsonSerializable()
class GetApiV1ArticlesResponse {
  const GetApiV1ArticlesResponse({required this.data, this.meta});

  factory GetApiV1ArticlesResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1ArticlesResponseFromJson(json);

  final List<ArticleCardDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1ArticlesResponseToJson(this);
}
