// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'admin_faq_dto.g.dart';

@JsonSerializable()
class AdminFaqDto {
  const AdminFaqDto({
    required this.id,
    required this.question,
    required this.answer,
    required this.sortOrder,
    required this.published,
  });
  
  factory AdminFaqDto.fromJson(Map<String, Object?> json) => _$AdminFaqDtoFromJson(json);
  
  final String id;
  final String question;
  final String answer;
  final num sortOrder;
  final bool published;

  Map<String, Object?> toJson() => _$AdminFaqDtoToJson(this);
}
