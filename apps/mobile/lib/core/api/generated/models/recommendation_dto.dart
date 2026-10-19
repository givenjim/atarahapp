// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'recommendation_dto_type.dart';

part 'recommendation_dto.g.dart';

@JsonSerializable()
class RecommendationDto {
  const RecommendationDto({
    required this.type,
    required this.id,
    required this.title,
    required this.path,
    required this.reason,
    this.subtitle,
    this.imageUrl,
  });

  factory RecommendationDto.fromJson(Map<String, Object?> json) =>
      _$RecommendationDtoFromJson(json);

  /// More kinds join as opportunities and Skill Labs arrive.
  final RecommendationDtoType type;
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;

  /// In-app route that opens it.
  final String path;

  /// Why it is suggested, e.g. "Because you selected Animation".
  final String reason;

  Map<String, Object?> toJson() => _$RecommendationDtoToJson(this);
}
