// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'reject_suggestion_dto.g.dart';

@JsonSerializable()
class RejectSuggestionDto {
  const RejectSuggestionDto({this.note});

  factory RejectSuggestionDto.fromJson(Map<String, Object?> json) =>
      _$RejectSuggestionDtoFromJson(json);

  final String? note;

  Map<String, Object?> toJson() => _$RejectSuggestionDtoToJson(this);
}
