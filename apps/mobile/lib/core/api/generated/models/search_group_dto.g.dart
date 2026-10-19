// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_group_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchGroupDto _$SearchGroupDtoFromJson(Map<String, dynamic> json) =>
    SearchGroupDto(
      type: SearchGroupDtoType.fromJson(json['type'] as String),
      count: json['count'] as num,
      items: (json['items'] as List<dynamic>)
          .map((e) => SearchHitDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SearchGroupDtoToJson(SearchGroupDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'count': instance.count,
      'items': instance.items,
    };
