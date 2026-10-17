// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_specialisation_suggestions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminSpecialisationSuggestionsResponse
_$GetApiV1AdminSpecialisationSuggestionsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminSpecialisationSuggestionsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => AdminSuggestionDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminSpecialisationSuggestionsResponseToJson(
  GetApiV1AdminSpecialisationSuggestionsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
