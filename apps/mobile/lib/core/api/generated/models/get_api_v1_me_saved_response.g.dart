// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_saved_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeSavedResponse _$GetApiV1MeSavedResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeSavedResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => SavedArticleDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeSavedResponseToJson(
  GetApiV1MeSavedResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
