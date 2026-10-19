// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_list_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConnectionListItemDto _$ConnectionListItemDtoFromJson(
  Map<String, dynamic> json,
) => ConnectionListItemDto(
  id: json['id'] as String,
  state: ConnectionListItemDtoState.fromJson(json['state'] as String),
  person: ConnectionPersonDto.fromJson(json['person'] as Map<String, dynamic>),
  since: DateTime.parse(json['since'] as String),
);

Map<String, dynamic> _$ConnectionListItemDtoToJson(
  ConnectionListItemDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'state': instance.state,
  'person': instance.person,
  'since': instance.since.toIso8601String(),
};
