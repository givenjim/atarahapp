// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_creatives_suggestions_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1CreativesSuggestionsResponse
_$GetApiV1CreativesSuggestionsResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1CreativesSuggestionsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => PersonToMeetDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1CreativesSuggestionsResponseToJson(
  GetApiV1CreativesSuggestionsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
