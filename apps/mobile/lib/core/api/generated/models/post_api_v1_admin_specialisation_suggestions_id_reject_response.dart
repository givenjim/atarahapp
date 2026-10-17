// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_suggestion_dto.dart';

part 'post_api_v1_admin_specialisation_suggestions_id_reject_response.g.dart';

@JsonSerializable()
class PostApiV1AdminSpecialisationSuggestionsIdRejectResponse {
  const PostApiV1AdminSpecialisationSuggestionsIdRejectResponse({
    required this.data,
    this.meta,
  });

  factory PostApiV1AdminSpecialisationSuggestionsIdRejectResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminSpecialisationSuggestionsIdRejectResponseFromJson(json);

  final AdminSuggestionDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminSpecialisationSuggestionsIdRejectResponseToJson(this);
}
