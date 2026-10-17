// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_suggestion_dto.dart';

part 'post_api_v1_admin_specialisation_suggestions_id_approve_response.g.dart';

@JsonSerializable()
class PostApiV1AdminSpecialisationSuggestionsIdApproveResponse {
  const PostApiV1AdminSpecialisationSuggestionsIdApproveResponse({
    required this.data,
    this.meta,
  });

  factory PostApiV1AdminSpecialisationSuggestionsIdApproveResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminSpecialisationSuggestionsIdApproveResponseFromJson(json);

  final AdminSuggestionDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminSpecialisationSuggestionsIdApproveResponseToJson(this);
}
