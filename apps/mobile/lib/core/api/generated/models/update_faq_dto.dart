// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'update_faq_dto.g.dart';

@JsonSerializable()
class UpdateFaqDto {
  const UpdateFaqDto({
    this.question,
    this.answer,
    this.sortOrder,
    this.published,
  });

  factory UpdateFaqDto.fromJson(Map<String, Object?> json) =>
      _$UpdateFaqDtoFromJson(json);

  final String? question;
  final String? answer;
  final num? sortOrder;
  final bool? published;

  Map<String, Object?> toJson() => _$UpdateFaqDtoToJson(this);
}
