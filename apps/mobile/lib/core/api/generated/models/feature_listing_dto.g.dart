// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_listing_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeatureListingDto _$FeatureListingDtoFromJson(Map<String, dynamic> json) =>
    FeatureListingDto(
      until: json['until'] == null
          ? null
          : DateTime.parse(json['until'] as String),
    );

Map<String, dynamic> _$FeatureListingDtoToJson(FeatureListingDto instance) =>
    <String, dynamic>{'until': instance.until?.toIso8601String()};
