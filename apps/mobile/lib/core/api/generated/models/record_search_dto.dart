// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'record_search_dto.g.dart';

@JsonSerializable()
class RecordSearchDto {
  const RecordSearchDto({required this.query});

  factory RecordSearchDto.fromJson(Map<String, Object?> json) =>
      _$RecordSearchDtoFromJson(json);

  final String query;

  Map<String, Object?> toJson() => _$RecordSearchDtoToJson(this);
}
