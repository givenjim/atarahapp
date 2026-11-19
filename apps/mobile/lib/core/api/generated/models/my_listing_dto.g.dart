// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_listing_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyListingDto _$MyListingDtoFromJson(Map<String, dynamic> json) => MyListingDto(
  featured: json['featured'] as bool,
  type: ListingType.fromJson(json['type'] as String),
  title: json['title'] as String,
  categoryName: json['categoryName'] as String,
  views30d: json['views30d'] as num,
  pricingType: PricingType.fromJson(json['pricingType'] as String),
  priceLabel: json['priceLabel'] as String,
  newInterest: json['newInterest'] as num,
  seller: SellerCardDto.fromJson(json['seller'] as Map<String, dynamic>),
  shareUrl: json['shareUrl'] as String,
  ratingCount: json['ratingCount'] as num,
  id: json['id'] as String,
  saved: json['saved'] as bool,
  status: ListingStatus.fromJson(json['status'] as String),
  description: json['description'] as String,
  includedItems: (json['includedItems'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  requestNote: json['requestNote'] as String,
  workMode: WorkMode.fromJson(json['workMode'] as String),
  isOwner: json['isOwner'] as bool,
  locationLabel: json['locationLabel'] as String,
  reviews: (json['reviews'] as List<dynamic>)
      .map((e) => ListingReviewDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  portfolio: (json['portfolio'] as List<dynamic>)
      .map(
        (e) => ListingPortfolioProjectDto.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  media: (json['media'] as List<dynamic>)
      .map((e) => ListingMediaDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  missing: (json['missing'] as List<dynamic>).map((e) => e as String).toList(),
  categoryId: json['categoryId'] as String,
  priceMin: json['priceMin'] as num?,
  audienceText: json['audienceText'] as String?,
  rejectionReason: json['rejectionReason'] as String?,
  locationText: json['locationText'] as String?,
  openEnquiryId: json['openEnquiryId'] as String?,
  deliveryDays: json['deliveryDays'] as num?,
  ratingAverage: json['ratingAverage'] as num?,
  fromLabel: json['fromLabel'] as String?,
  coverUrl: json['coverUrl'] as String?,
  profileServiceId: json['profileServiceId'] as String?,
  priceMax: json['priceMax'] as num?,
);

Map<String, dynamic> _$MyListingDtoToJson(MyListingDto instance) =>
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
      'newInterest': instance.newInterest,
      'views30d': instance.views30d,
      'profileServiceId': instance.profileServiceId,
      'missing': instance.missing,
    };
