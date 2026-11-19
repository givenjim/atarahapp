// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_home_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MarketplaceHomeDto _$MarketplaceHomeDtoFromJson(Map<String, dynamic> json) =>
    MarketplaceHomeDto(
      isSeller: json['isSeller'] as bool,
      categories: (json['categories'] as List<dynamic>)
          .map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      featured: (json['featured'] as List<dynamic>)
          .map((e) => ListingCardDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      popularSellers: (json['popularSellers'] as List<dynamic>)
          .map((e) => SellerCardDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      recent: (json['recent'] as List<dynamic>)
          .map((e) => ListingCardDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MarketplaceHomeDtoToJson(MarketplaceHomeDto instance) =>
    <String, dynamic>{
      'isSeller': instance.isSeller,
      'categories': instance.categories,
      'featured': instance.featured,
      'popularSellers': instance.popularSellers,
      'recent': instance.recent,
    };
