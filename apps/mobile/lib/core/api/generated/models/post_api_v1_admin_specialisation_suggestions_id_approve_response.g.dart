// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_specialisation_suggestions_id_approve_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminSpecialisationSuggestionsIdApproveResponse
_$PostApiV1AdminSpecialisationSuggestionsIdApproveResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminSpecialisationSuggestionsIdApproveResponse(
  data: AdminSuggestionDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic>
_$PostApiV1AdminSpecialisationSuggestionsIdApproveResponseToJson(
  PostApiV1AdminSpecialisationSuggestionsIdApproveResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
