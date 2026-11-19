// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_marketplace_category_dto.dart';

part 'patch_api_v1_admin_marketplace_categories_id_response.g.dart';

@JsonSerializable()
class PatchApiV1AdminMarketplaceCategoriesIdResponse {
  const PatchApiV1AdminMarketplaceCategoriesIdResponse({
    required this.data,
    this.meta,
  });
  
  factory PatchApiV1AdminMarketplaceCategoriesIdResponse.fromJson(Map<String, Object?> json) => _$PatchApiV1AdminMarketplaceCategoriesIdResponseFromJson(json);
  
  final AdminMarketplaceCategoryDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PatchApiV1AdminMarketplaceCategoriesIdResponseToJson(this);
}
