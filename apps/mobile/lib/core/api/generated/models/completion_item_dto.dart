// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'completion_item_dto.g.dart';

@JsonSerializable()
class CompletionItemDto {
  const CompletionItemDto({
    required this.key,
    required this.label,
    required this.weight,
    required this.done,
  });

  factory CompletionItemDto.fromJson(Map<String, Object?> json) =>
      _$CompletionItemDtoFromJson(json);

  final String key;
  final String label;
  final num weight;
  final bool done;

  Map<String, Object?> toJson() => _$CompletionItemDtoToJson(this);
}
