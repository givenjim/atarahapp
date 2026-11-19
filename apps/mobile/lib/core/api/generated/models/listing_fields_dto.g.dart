// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_fields_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListingFieldsDto _$ListingFieldsDtoFromJson(Map<String, dynamic> json) =>
    ListingFieldsDto(
      type: json['type'] == null
          ? null
          : ListingType.fromJson(json['type'] as String),
      title: json['title'] as String?,
      categoryId: json['categoryId'] as String?,
      description: json['description'] as String?,
      includedItems: (json['includedItems'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      deliveryDays: json['deliveryDays'] as num?,
      workMode: json['workMode'] == null
          ? null
          : WorkMode.fromJson(json['workMode'] as String),
      locationText: json['locationText'] as String?,
      audienceText: json['audienceText'] as String?,
      pricingType: json['pricingType'] == null
          ? null
          : PricingType.fromJson(json['pricingType'] as String),
      priceMin: json['priceMin'] as num?,
      priceMax: json['priceMax'] as num?,
      mediaIds: (json['mediaIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      projectIds: (json['projectIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ListingFieldsDtoToJson(ListingFieldsDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'categoryId': instance.categoryId,
      'description': instance.description,
      'includedItems': instance.includedItems,
      'deliveryDays': instance.deliveryDays,
      'workMode': instance.workMode,
      'locationText': instance.locationText,
      'audienceText': instance.audienceText,
      'pricingType': instance.pricingType,
      'priceMin': instance.priceMin,
      'priceMax': instance.priceMax,
      'mediaIds': instance.mediaIds,
      'projectIds': instance.projectIds,
    };
