// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_taxonomy_item_dto.dart';

part 'post_api_v1_admin_taxonomy_kind_response.g.dart';

@JsonSerializable()
class PostApiV1AdminTaxonomyKindResponse {
  const PostApiV1AdminTaxonomyKindResponse({required this.data, this.meta});

  factory PostApiV1AdminTaxonomyKindResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminTaxonomyKindResponseFromJson(json);

  final AdminTaxonomyItemDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminTaxonomyKindResponseToJson(this);
}
