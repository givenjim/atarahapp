// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_opportunity_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeatureOpportunityDto _$FeatureOpportunityDtoFromJson(
  Map<String, dynamic> json,
) => FeatureOpportunityDto(
  until: json['until'] == null ? null : DateTime.parse(json['until'] as String),
);

Map<String, dynamic> _$FeatureOpportunityDtoToJson(
  FeatureOpportunityDto instance,
) => <String, dynamic>{'until': instance.until?.toIso8601String()};
