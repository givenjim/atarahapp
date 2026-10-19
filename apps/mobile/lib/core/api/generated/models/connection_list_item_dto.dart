// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'connection_list_item_dto_state.dart';
import 'connection_person_dto.dart';

part 'connection_list_item_dto.g.dart';

@JsonSerializable()
class ConnectionListItemDto {
  const ConnectionListItemDto({
    required this.id,
    required this.state,
    required this.person,
    required this.since,
  });

  factory ConnectionListItemDto.fromJson(Map<String, Object?> json) =>
      _$ConnectionListItemDtoFromJson(json);

  final String id;
  final ConnectionListItemDtoState state;
  final ConnectionPersonDto person;
  final DateTime since;

  Map<String, Object?> toJson() => _$ConnectionListItemDtoToJson(this);
}
