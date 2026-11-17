// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'learning_card_dto.dart';

part 'recommended_dto.g.dart';

@JsonSerializable()
class RecommendedDto {
  const RecommendedDto({required this.content, required this.reason});

  factory RecommendedDto.fromJson(Map<String, Object?> json) =>
      _$RecommendedDtoFromJson(json);

  final LearningCardDto content;

  /// Why: "Because you want to develop Personal branding".
  final String reason;

  Map<String, Object?> toJson() => _$RecommendedDtoToJson(this);
}
