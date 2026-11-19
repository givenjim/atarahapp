// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'listing_type.dart';
import 'pricing_type.dart';
import 'work_mode.dart';

part 'create_listing_dto.g.dart';

@JsonSerializable()
class CreateListingDto {
  const CreateListingDto({
    required this.type,
    required this.title,
    required this.categoryId,
    required this.description,
    required this.includedItems,
    required this.deliveryDays,
    required this.workMode,
    required this.locationText,
    required this.audienceText,
    required this.pricingType,
    required this.priceMin,
    required this.priceMax,
    required this.mediaIds,
    required this.projectIds,
    required this.acceptTerms,
    required this.termsVersion,
  });
  
  factory CreateListingDto.fromJson(Map<String, Object?> json) => _$CreateListingDtoFromJson(json);
  
  final ListingType? type;
  final String? title;
  final String? categoryId;
  final String? description;
  final List<String>? includedItems;

  /// Delivery time in days; 0 clears it.
  final num? deliveryDays;
  final WorkMode? workMode;
  final String? locationText;

  /// Who it is for.
  final String? audienceText;
  final PricingType? pricingType;

  /// Whole shillings. FIXED and RANGE.
  final num? priceMin;

  /// Whole shillings. RANGE only.
  final num? priceMax;

  /// Uploaded public images, in order. The first is the cover.
  final List<String>? mediaIds;

  /// The member’s own published projects to show as examples.
  final List<String>? projectIds;

  /// Required for a member who is not a seller yet: accepts the seller terms and makes them a seller.
  final bool? acceptTerms;

  /// The version of the terms that was shown.
  final String? termsVersion;

  Map<String, Object?> toJson() => _$CreateListingDtoToJson(this);
}
