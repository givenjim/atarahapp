// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'merge_suggestion_dto.g.dart';

@JsonSerializable()
class MergeSuggestionDto {
  const MergeSuggestionDto({required this.specialisationId});

  factory MergeSuggestionDto.fromJson(Map<String, Object?> json) =>
      _$MergeSuggestionDtoFromJson(json);

  /// The existing specialisation this suggestion duplicates.
  final String specialisationId;

  Map<String, Object?> toJson() => _$MergeSuggestionDtoToJson(this);
}
