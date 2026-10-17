// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_suggestion_dto.dart';

part 'get_api_v1_admin_specialisation_suggestions_response.g.dart';

@JsonSerializable()
class GetApiV1AdminSpecialisationSuggestionsResponse {
  const GetApiV1AdminSpecialisationSuggestionsResponse({
    required this.data,
    this.meta,
  });

  factory GetApiV1AdminSpecialisationSuggestionsResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1AdminSpecialisationSuggestionsResponseFromJson(json);

  final List<AdminSuggestionDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1AdminSpecialisationSuggestionsResponseToJson(this);
}
