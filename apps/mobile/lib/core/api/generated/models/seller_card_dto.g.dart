// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_card_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SellerCardDto _$SellerCardDtoFromJson(Map<String, dynamic> json) =>
    SellerCardDto(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      ratingCount: json['ratingCount'] as num,
      completedCount: json['completedCount'] as num,
      listingCount: json['listingCount'] as num,
      verified: json['verified'] as bool,
      handle: json['handle'] as String?,
      headline: json['headline'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      ratingAverage: json['ratingAverage'] as num?,
    );

Map<String, dynamic> _$SellerCardDtoToJson(SellerCardDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'handle': instance.handle,
      'headline': instance.headline,
      'avatarUrl': instance.avatarUrl,
      'ratingAverage': instance.ratingAverage,
      'ratingCount': instance.ratingCount,
      'completedCount': instance.completedCount,
      'listingCount': instance.listingCount,
      'verified': instance.verified,
    };
