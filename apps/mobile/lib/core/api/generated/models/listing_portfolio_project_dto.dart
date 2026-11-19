// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'listing_portfolio_project_dto.g.dart';

@JsonSerializable()
class ListingPortfolioProjectDto {
  const ListingPortfolioProjectDto({
    required this.id,
    required this.title,
    this.coverUrl,
    this.category,
  });
  
  factory ListingPortfolioProjectDto.fromJson(Map<String, Object?> json) => _$ListingPortfolioProjectDtoFromJson(json);
  
  final String id;
  final String title;
  final String? coverUrl;
  final String? category;

  Map<String, Object?> toJson() => _$ListingPortfolioProjectDtoToJson(this);
}
