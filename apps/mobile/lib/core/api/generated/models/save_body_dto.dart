// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'save_body_dto.g.dart';

@JsonSerializable()
class SaveBodyDto {
  const SaveBodyDto({this.collection});

  factory SaveBodyDto.fromJson(Map<String, Object?> json) =>
      _$SaveBodyDtoFromJson(json);

  /// File it under this collection. Empty clears it.
  final String? collection;

  Map<String, Object?> toJson() => _$SaveBodyDtoToJson(this);
}
