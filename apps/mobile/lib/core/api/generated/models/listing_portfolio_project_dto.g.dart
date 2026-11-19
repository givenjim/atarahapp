// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_portfolio_project_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListingPortfolioProjectDto _$ListingPortfolioProjectDtoFromJson(
  Map<String, dynamic> json,
) => ListingPortfolioProjectDto(
  id: json['id'] as String,
  title: json['title'] as String,
  coverUrl: json['coverUrl'] as String?,
  category: json['category'] as String?,
);

Map<String, dynamic> _$ListingPortfolioProjectDtoToJson(
  ListingPortfolioProjectDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'coverUrl': instance.coverUrl,
  'category': instance.category,
};
