// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_article_list_item_dto.dart';

part 'get_api_v1_admin_articles_response.g.dart';

@JsonSerializable()
class GetApiV1AdminArticlesResponse {
  const GetApiV1AdminArticlesResponse({required this.data, this.meta});

  factory GetApiV1AdminArticlesResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1AdminArticlesResponseFromJson(json);

  final List<AdminArticleListItemDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminArticlesResponseToJson(this);
}
