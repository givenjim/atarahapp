// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'feature_opportunity_dto.g.dart';

@JsonSerializable()
class FeatureOpportunityDto {
  const FeatureOpportunityDto({
    this.until,
  });
  
  factory FeatureOpportunityDto.fromJson(Map<String, Object?> json) => _$FeatureOpportunityDtoFromJson(json);
  
  /// Feature until this time. Null (or omitted) removes the feature.
  final DateTime? until;

  Map<String, Object?> toJson() => _$FeatureOpportunityDtoToJson(this);
}
