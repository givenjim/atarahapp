// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_specialisation_suggestions_id_reject_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminSpecialisationSuggestionsIdRejectResponse
_$PostApiV1AdminSpecialisationSuggestionsIdRejectResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminSpecialisationSuggestionsIdRejectResponse(
  data: AdminSuggestionDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic>
_$PostApiV1AdminSpecialisationSuggestionsIdRejectResponseToJson(
  PostApiV1AdminSpecialisationSuggestionsIdRejectResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
