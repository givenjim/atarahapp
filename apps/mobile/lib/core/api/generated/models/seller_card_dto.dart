// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'seller_card_dto.g.dart';

@JsonSerializable()
class SellerCardDto {
  const SellerCardDto({
    required this.id,
    required this.displayName,
    required this.ratingCount,
    required this.completedCount,
    required this.listingCount,
    required this.verified,
    this.handle,
    this.headline,
    this.avatarUrl,
    this.ratingAverage,
  });
  
  factory SellerCardDto.fromJson(Map<String, Object?> json) => _$SellerCardDtoFromJson(json);
  
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

  Map<String, Object?> toJson() => _$SellerCardDtoToJson(this);
}
