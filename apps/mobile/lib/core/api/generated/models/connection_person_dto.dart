// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'connection_person_dto.g.dart';

@JsonSerializable()
class ConnectionPersonDto {
  const ConnectionPersonDto({
    required this.handle,
    required this.displayName,
    required this.avatarUrl,
    required this.headline,
    required this.discipline,
  });

  factory ConnectionPersonDto.fromJson(Map<String, Object?> json) =>
      _$ConnectionPersonDtoFromJson(json);

  final String handle;
  final String displayName;
  final String? avatarUrl;
  final String? headline;
  final String? discipline;

  Map<String, Object?> toJson() => _$ConnectionPersonDtoToJson(this);
}
