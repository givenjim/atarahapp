// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'listing_card_dto.dart';
import 'my_listings_stats_dto.dart';
import 'seller_status.dart';

part 'my_listings_dto.g.dart';

@JsonSerializable()
class MyListingsDto {
  const MyListingsDto({
    required this.isSeller,
    required this.stats,
    required this.listings,
    this.sellerStatus,
  });
  
  factory MyListingsDto.fromJson(Map<String, Object?> json) => _$MyListingsDtoFromJson(json);
  
  final bool isSeller;
  final SellerStatus? sellerStatus;
  final MyListingsStatsDto stats;
  final List<ListingCardDto> listings;

  Map<String, Object?> toJson() => _$MyListingsDtoToJson(this);
}
