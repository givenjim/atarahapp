// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'listing_card_dto.dart';

part 'seller_profile_dto.g.dart';

@JsonSerializable()
class SellerProfileDto {
  const SellerProfileDto({
    required this.id,
    required this.displayName,
    required this.ratingCount,
    required this.completedCount,
    required this.listingCount,
    required this.verified,
    required this.userId,
    required this.trustLines,
    required this.memberSince,
    required this.listings,
    required this.hasProfile,
    this.handle,
    this.headline,
    this.avatarUrl,
    this.ratingAverage,
    this.medianReplyMinutes,
    this.replyLabel,
    this.bio,
    this.location,
  });
  
  factory SellerProfileDto.fromJson(Map<String, Object?> json) => _$SellerProfileDtoFromJson(json);
  
  /// The seller profile id.
  final String id;
  final String displayName;
  final String? handle;
  final String? headline;
  final String? avatarUrl;
  final num? ratingAverage;
  final num ratingCount;
  final num completedCount;

  /// Published listings.
  final num listingCount;

  /// True only when the seller is verified by Atarah (written by P2-M6).
  final bool verified;
  final String userId;

  /// Median first reply, in minutes.
  final num? medianReplyMinutes;

  /// Ready to show: "Replies within 3 hours".
  final String? replyLabel;

  /// Only real trust lines, for example "Identity verified by Atarah". Empty when there are none.
  final List<String> trustLines;
  final String? bio;
  final String? location;
  final DateTime memberSince;

  /// Services and products that are live.
  final List<ListingCardDto> listings;

  /// Public creative profile handle exists and can be opened.
  final bool hasProfile;

  Map<String, Object?> toJson() => _$SellerProfileDtoToJson(this);
}
