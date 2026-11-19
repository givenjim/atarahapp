// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListingDto _$ListingDtoFromJson(Map<String, dynamic> json) => ListingDto(
  id: json['id'] as String,
  type: ListingType.fromJson(json['type'] as String),
  title: json['title'] as String,
  categoryName: json['categoryName'] as String,
  pricingType: PricingType.fromJson(json['pricingType'] as String),
  priceLabel: json['priceLabel'] as String,
  seller: SellerCardDto.fromJson(json['seller'] as Map<String, dynamic>),
  ratingCount: json['ratingCount'] as num,
  featured: json['featured'] as bool,
  saved: json['saved'] as bool,
  status: ListingStatus.fromJson(json['status'] as String),
  description: json['description'] as String,
  includedItems: (json['includedItems'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  workMode: WorkMode.fromJson(json['workMode'] as String),
  locationLabel: json['locationLabel'] as String,
  categoryId: json['categoryId'] as String,
  media: (json['media'] as List<dynamic>)
      .map((e) => ListingMediaDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  portfolio: (json['portfolio'] as List<dynamic>)
      .map(
        (e) => ListingPortfolioProjectDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  reviews: (json['reviews'] as List<dynamic>)
      .map((e) => ListingReviewDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  isOwner: json['isOwner'] as bool,
  requestNote: json['requestNote'] as String,
  shareUrl: json['shareUrl'] as String,
  coverUrl: json['coverUrl'] as String?,
  fromLabel: json['fromLabel'] as String?,
  ratingAverage: json['ratingAverage'] as num?,
  deliveryDays: json['deliveryDays'] as num?,
  locationText: json['locationText'] as String?,
  audienceText: json['audienceText'] as String?,
  priceMin: json['priceMin'] as num?,
  priceMax: json['priceMax'] as num?,
  rejectionReason: json['rejectionReason'] as String?,
  openEnquiryId: json['openEnquiryId'] as String?,
);

Map<String, dynamic> _$ListingDtoToJson(ListingDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'categoryName': instance.categoryName,
      'coverUrl': instance.coverUrl,
      'pricingType': instance.pricingType,
      'priceLabel': instance.priceLabel,
      'fromLabel': instance.fromLabel,
      'seller': instance.seller,
      'ratingAverage': instance.ratingAverage,
      'ratingCount': instance.ratingCount,
      'featured': instance.featured,
      'saved': instance.saved,
      'status': instance.status,
      'description': instance.description,
      'includedItems': instance.includedItems,
      'deliveryDays': instance.deliveryDays,
      'workMode': instance.workMode,
      'locationText': instance.locationText,
      'locationLabel': instance.locationLabel,
      'audienceText': instance.audienceText,
      'priceMin': instance.priceMin,
      'priceMax': instance.priceMax,
      'categoryId': instance.categoryId,
      'media': instance.media,
      'portfolio': instance.portfolio,
      'reviews': instance.reviews,
      'rejectionReason': instance.rejectionReason,
      'isOwner': instance.isOwner,
      'openEnquiryId': instance.openEnquiryId,
      'requestNote': instance.requestNote,
      'shareUrl': instance.shareUrl,
    };
