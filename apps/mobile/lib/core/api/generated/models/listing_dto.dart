// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'listing_media_dto.dart';
import 'listing_portfolio_project_dto.dart';
import 'listing_review_dto.dart';
import 'listing_status.dart';
import 'listing_type.dart';
import 'pricing_type.dart';
import 'seller_card_dto.dart';
import 'work_mode.dart';

part 'listing_dto.g.dart';

@JsonSerializable()
class ListingDto {
  const ListingDto({
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
    required this.workMode,
    required this.locationLabel,
    required this.categoryId,
    required this.media,
    required this.portfolio,
    required this.reviews,
    required this.isOwner,
    required this.requestNote,
    required this.shareUrl,
    this.coverUrl,
    this.fromLabel,
    this.ratingAverage,
    this.deliveryDays,
    this.locationText,
    this.audienceText,
    this.priceMin,
    this.priceMax,
    this.rejectionReason,
    this.openEnquiryId,
  });
  
  factory ListingDto.fromJson(Map<String, Object?> json) => _$ListingDtoFromJson(json);
  
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
  final num? deliveryDays;
  final WorkMode workMode;
  final String? locationText;

  /// Ready to show: "Remote", "Nairobi", "Hybrid · Nairobi".
  final String locationLabel;
  final String? audienceText;

  /// Whole shillings.
  final num? priceMin;

  /// Whole shillings (RANGE).
  final num? priceMax;
  final String categoryId;
  final List<ListingMediaDto> media;
  final List<ListingPortfolioProjectDto> portfolio;

  /// The latest few. The full list has its own endpoint.
  final List<ListingReviewDto> reviews;
  final String? rejectionReason;

  /// The viewer owns the listing.
  final bool isOwner;

  /// The viewer already has an open request on this listing.
  final String? openEnquiryId;

  /// The one-line note shown under the request button.
  final String requestNote;

  /// Public share address.
  final String shareUrl;

  Map<String, Object?> toJson() => _$ListingDtoToJson(this);
}
