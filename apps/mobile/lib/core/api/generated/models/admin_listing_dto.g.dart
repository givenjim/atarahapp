// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_listing_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminListingDto _$AdminListingDtoFromJson(Map<String, dynamic> json) =>
    AdminListingDto(
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
      media: (json['media'] as List<dynamic>)
          .map((e) => ListingMediaDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      openReports: json['openReports'] as num,
      sellerStatus: SellerStatus.fromJson(json['sellerStatus'] as String),
      sellerApprovedBefore: json['sellerApprovedBefore'] as num,
      coverUrl: json['coverUrl'] as String?,
      fromLabel: json['fromLabel'] as String?,
      ratingAverage: json['ratingAverage'] as num?,
      rejectionReason: json['rejectionReason'] as String?,
      suspendedReason: json['suspendedReason'] as String?,
      featuredUntil: json['featuredUntil'] == null
          ? null
          : DateTime.parse(json['featuredUntil'] as String),
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
    );

Map<String, dynamic> _$AdminListingDtoToJson(AdminListingDto instance) =>
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
      'media': instance.media,
      'rejectionReason': instance.rejectionReason,
      'suspendedReason': instance.suspendedReason,
      'featuredUntil': instance.featuredUntil?.toIso8601String(),
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'openReports': instance.openReports,
      'sellerStatus': instance.sellerStatus,
      'sellerApprovedBefore': instance.sellerApprovedBefore,
    };
