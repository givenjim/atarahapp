// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_specialisation_suggestions_id_merge_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminSpecialisationSuggestionsIdMergeResponse
_$PostApiV1AdminSpecialisationSuggestionsIdMergeResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminSpecialisationSuggestionsIdMergeResponse(
  data: AdminSuggestionDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic>
_$PostApiV1AdminSpecialisationSuggestionsIdMergeResponseToJson(
  PostApiV1AdminSpecialisationSuggestionsIdMergeResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
