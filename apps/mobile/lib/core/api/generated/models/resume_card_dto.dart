// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'resume_card_dto_kind.dart';

part 'resume_card_dto.g.dart';

@JsonSerializable()
class ResumeCardDto {
  const ResumeCardDto({
    required this.kind,
    required this.title,
    required this.path,
    required this.updatedAt,
    this.subtitle,
    this.progressPercent,
  });
  
  factory ResumeCardDto.fromJson(Map<String, Object?> json) => _$ResumeCardDtoFromJson(json);
  
  final ResumeCardDtoKind kind;
  final String title;
  final String? subtitle;

  /// 0 to 100 where progress makes sense.
  final num? progressPercent;

  /// The in-app path that opens it.
  final String path;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => _$ResumeCardDtoToJson(this);
}
