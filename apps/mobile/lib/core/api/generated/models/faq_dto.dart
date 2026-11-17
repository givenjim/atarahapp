// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'faq_dto.g.dart';

@JsonSerializable()
class FaqDto {
  const FaqDto({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory FaqDto.fromJson(Map<String, Object?> json) => _$FaqDtoFromJson(json);

  final String id;
  final String question;
  final String answer;

  Map<String, Object?> toJson() => _$FaqDtoToJson(this);
}
