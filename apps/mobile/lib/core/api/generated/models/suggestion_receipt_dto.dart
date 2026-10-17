// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'suggestion_receipt_dto_status.dart';

part 'suggestion_receipt_dto.g.dart';

@JsonSerializable()
class SuggestionReceiptDto {
  const SuggestionReceiptDto({
    required this.id,
    required this.name,
    required this.status,
  });

  factory SuggestionReceiptDto.fromJson(Map<String, Object?> json) =>
      _$SuggestionReceiptDtoFromJson(json);

  final String id;
  final String name;
  final SuggestionReceiptDtoStatus status;

  Map<String, Object?> toJson() => _$SuggestionReceiptDtoToJson(this);
}
