// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_card_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListingCardDto _$ListingCardDtoFromJson(Map<String, dynamic> json) =>
    ListingCardDto(
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
      coverUrl: json['coverUrl'] as String?,
      fromLabel: json['fromLabel'] as String?,
      ratingAverage: json['ratingAverage'] as num?,
    );

Map<String, dynamic> _$ListingCardDtoToJson(ListingCardDto instance) =>
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
    };
