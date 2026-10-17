// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_taxonomy_specialisations_suggestions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1TaxonomySpecialisationsSuggestionsResponse
_$PostApiV1TaxonomySpecialisationsSuggestionsResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1TaxonomySpecialisationsSuggestionsResponse(
  data: SuggestionReceiptDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic>
_$PostApiV1TaxonomySpecialisationsSuggestionsResponseToJson(
  PostApiV1TaxonomySpecialisationsSuggestionsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
