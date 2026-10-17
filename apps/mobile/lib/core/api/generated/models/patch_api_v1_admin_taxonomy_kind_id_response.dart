// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_taxonomy_item_dto.dart';

part 'patch_api_v1_admin_taxonomy_kind_id_response.g.dart';

@JsonSerializable()
class PatchApiV1AdminTaxonomyKindIdResponse {
  const PatchApiV1AdminTaxonomyKindIdResponse({required this.data, this.meta});

  factory PatchApiV1AdminTaxonomyKindIdResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PatchApiV1AdminTaxonomyKindIdResponseFromJson(json);

  final AdminTaxonomyItemDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PatchApiV1AdminTaxonomyKindIdResponseToJson(this);
}
