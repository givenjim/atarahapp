// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'listing_status.dart';
import 'listing_type.dart';
import 'pricing_type.dart';
import 'seller_card_dto.dart';

part 'listing_card_dto.g.dart';

@JsonSerializable()
class ListingCardDto {
  const ListingCardDto({
    required this.id,
    required this.type,
    required this.title,
    required this.categoryName,
    required this.pricingType,
    required this.priceLabel,
    required this.seller,
    required this.ratingCount,
    required this.featured,
    required this.saved,
    required this.status,
    this.coverUrl,
    this.fromLabel,
    this.ratingAverage,
  });
  
  factory ListingCardDto.fromJson(Map<String, Object?> json) => _$ListingCardDtoFromJson(json);
  
  final String id;
  final ListingType type;
  final String title;
  final String categoryName;
  final String? coverUrl;
  final PricingType pricingType;

  /// Ready to show: "KES 5,000", "KES 5,000 to KES 9,000", "Price on request".
  final String priceLabel;

  /// "From KES 5,000".
  final String? fromLabel;
  final SellerCardDto seller;
  final num? ratingAverage;
  final num ratingCount;
  final bool featured;

  /// The member saved it.
  final bool saved;
  final ListingStatus status;

  Map<String, Object?> toJson() => _$ListingCardDtoToJson(this);
}
