// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'completion_item_dto.dart';

part 'completion_dto.g.dart';

@JsonSerializable()
class CompletionDto {
  const CompletionDto({
    required this.percent,
    required this.items,
    required this.next,
  });

  factory CompletionDto.fromJson(Map<String, Object?> json) =>
      _$CompletionDtoFromJson(json);

  final num percent;
  final List<CompletionItemDto> items;

  /// The most valuable missing items, heaviest first.
  final List<CompletionItemDto> next;

  Map<String, Object?> toJson() => _$CompletionDtoToJson(this);
}
