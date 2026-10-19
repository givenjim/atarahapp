// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'article_card_dto.dart';
import 'creative_card_dto.dart';
import 'home_dto_unavailable.dart';
import 'recommendation_dto.dart';

part 'home_dto.g.dart';

@JsonSerializable()
class HomeDto {
  const HomeDto({
    required this.firstName,
    required this.completionPercent,
    required this.unreadNotifications,
    required this.recommended,
    required this.creatives,
    required this.unavailable,
    this.article,
  });

  factory HomeDto.fromJson(Map<String, Object?> json) =>
      _$HomeDtoFromJson(json);

  final String firstName;
  final num completionPercent;
  final num unreadNotifications;

  /// The pinned article, else the newest.
  final ArticleCardDto? article;
  final List<RecommendationDto> recommended;
  final List<CreativeCardDto> creatives;

  /// Sections that could not be loaded this time. The client hides them.
  final List<HomeDtoUnavailable> unavailable;

  Map<String, Object?> toJson() => _$HomeDtoToJson(this);
}
