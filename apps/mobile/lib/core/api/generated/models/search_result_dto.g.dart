// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResultDto _$SearchResultDtoFromJson(Map<String, dynamic> json) =>
    SearchResultDto(
      query: json['query'] as String,
      groups: (json['groups'] as List<dynamic>)
          .map((e) => SearchGroupDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SearchResultDtoToJson(SearchResultDto instance) =>
    <String, dynamic>{'query': instance.query, 'groups': instance.groups};
