// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'suggestion_receipt_dto.dart';

part 'post_api_v1_taxonomy_specialisations_suggestions_response.g.dart';

@JsonSerializable()
class PostApiV1TaxonomySpecialisationsSuggestionsResponse {
  const PostApiV1TaxonomySpecialisationsSuggestionsResponse({
    required this.data,
    this.meta,
  });

  factory PostApiV1TaxonomySpecialisationsSuggestionsResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1TaxonomySpecialisationsSuggestionsResponseFromJson(json);

  final SuggestionReceiptDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1TaxonomySpecialisationsSuggestionsResponseToJson(this);
}
