// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'approve_suggestion_dto.g.dart';

@JsonSerializable()
class ApproveSuggestionDto {
  const ApproveSuggestionDto({this.name});

  factory ApproveSuggestionDto.fromJson(Map<String, Object?> json) =>
      _$ApproveSuggestionDtoFromJson(json);

  /// Publish it under a corrected name.
  final String? name;

  Map<String, Object?> toJson() => _$ApproveSuggestionDtoToJson(this);
}
