// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'taxonomy_item_dto.dart';

part 'get_api_v1_taxonomy_development_areas_response.g.dart';

@JsonSerializable()
class GetApiV1TaxonomyDevelopmentAreasResponse {
  const GetApiV1TaxonomyDevelopmentAreasResponse({
    required this.data,
    this.meta,
  });

  factory GetApiV1TaxonomyDevelopmentAreasResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1TaxonomyDevelopmentAreasResponseFromJson(json);

  final List<TaxonomyItemDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1TaxonomyDevelopmentAreasResponseToJson(this);
}
