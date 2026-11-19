// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'listing_media_dto.dart';
import 'listing_status.dart';
import 'listing_type.dart';
import 'pricing_type.dart';
import 'seller_card_dto.dart';
import 'seller_status.dart';

part 'admin_listing_dto.g.dart';

@JsonSerializable()
class AdminListingDto {
  const AdminListingDto({
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
    required this.description,
    required this.includedItems,
    required this.media,
    required this.createdAt,
    required this.openReports,
    required this.sellerStatus,
    required this.sellerApprovedBefore,
    this.coverUrl,
    this.fromLabel,
    this.ratingAverage,
    this.rejectionReason,
    this.suspendedReason,
    this.featuredUntil,
    this.publishedAt,
  });
  
  factory AdminListingDto.fromJson(Map<String, Object?> json) => _$AdminListingDtoFromJson(json);
  
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
  final String description;
  final List<String> includedItems;
  final List<ListingMediaDto> media;
  final String? rejectionReason;
  final String? suspendedReason;
  final DateTime? featuredUntil;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final num openReports;
  final SellerStatus sellerStatus;
  final num sellerApprovedBefore;

  Map<String, Object?> toJson() => _$AdminListingDtoToJson(this);
}
