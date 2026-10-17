// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_taxonomy_item_dto.dart';

part 'get_api_v1_admin_taxonomy_kind_response.g.dart';

@JsonSerializable()
class GetApiV1AdminTaxonomyKindResponse {
  const GetApiV1AdminTaxonomyKindResponse({required this.data, this.meta});

  factory GetApiV1AdminTaxonomyKindResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1AdminTaxonomyKindResponseFromJson(json);

  final List<AdminTaxonomyItemDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1AdminTaxonomyKindResponseToJson(this);
}
