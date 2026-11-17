// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'faq_fields_dto.g.dart';

@JsonSerializable()
class FaqFieldsDto {
  const FaqFieldsDto({
    required this.question,
    required this.answer,
    this.sortOrder,
    this.published,
  });

  factory FaqFieldsDto.fromJson(Map<String, Object?> json) =>
      _$FaqFieldsDtoFromJson(json);

  final String question;
  final String answer;
  final num? sortOrder;
  final bool? published;

  Map<String, Object?> toJson() => _$FaqFieldsDtoToJson(this);
}
