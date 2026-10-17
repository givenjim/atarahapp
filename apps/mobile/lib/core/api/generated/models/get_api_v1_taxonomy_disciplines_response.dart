// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'discipline_dto.dart';

part 'get_api_v1_taxonomy_disciplines_response.g.dart';

@JsonSerializable()
class GetApiV1TaxonomyDisciplinesResponse {
  const GetApiV1TaxonomyDisciplinesResponse({required this.data, this.meta});

  factory GetApiV1TaxonomyDisciplinesResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1TaxonomyDisciplinesResponseFromJson(json);

  final List<DisciplineDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1TaxonomyDisciplinesResponseToJson(this);
}
