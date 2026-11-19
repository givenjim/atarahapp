// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'category_dto.dart';
import 'listing_card_dto.dart';
import 'seller_card_dto.dart';

part 'marketplace_home_dto.g.dart';

@JsonSerializable()
class MarketplaceHomeDto {
  const MarketplaceHomeDto({
    required this.isSeller,
    required this.categories,
    required this.featured,
    required this.popularSellers,
    required this.recent,
  });
  
  factory MarketplaceHomeDto.fromJson(Map<String, Object?> json) => _$MarketplaceHomeDtoFromJson(json);
  
  /// The member holds the seller role (shows "My listings").
  final bool isSeller;
  final List<CategoryDto> categories;
  final List<ListingCardDto> featured;
  final List<SellerCardDto> popularSellers;

  /// Newest live listings.
  final List<ListingCardDto> recent;

  Map<String, Object?> toJson() => _$MarketplaceHomeDtoToJson(this);
}
