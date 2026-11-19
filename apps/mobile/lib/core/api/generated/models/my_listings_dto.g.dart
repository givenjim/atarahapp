// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_listings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyListingsDto _$MyListingsDtoFromJson(Map<String, dynamic> json) =>
    MyListingsDto(
      isSeller: json['isSeller'] as bool,
      stats: MyListingsStatsDto.fromJson(json['stats'] as Map<String, dynamic>),
      listings: (json['listings'] as List<dynamic>)
          .map((e) => ListingCardDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      sellerStatus: json['sellerStatus'] == null
          ? null
          : SellerStatus.fromJson(json['sellerStatus'] as String),
    );

Map<String, dynamic> _$MyListingsDtoToJson(MyListingsDto instance) =>
    <String, dynamic>{
      'isSeller': instance.isSeller,
      'sellerStatus': instance.sellerStatus,
      'stats': instance.stats,
      'listings': instance.listings,
    };
