// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'feature_listing_dto.g.dart';

@JsonSerializable()
class FeatureListingDto {
  const FeatureListingDto({
    this.until,
  });
  
  factory FeatureListingDto.fromJson(Map<String, Object?> json) => _$FeatureListingDtoFromJson(json);
  
  /// Null un-features.
  final DateTime? until;

  Map<String, Object?> toJson() => _$FeatureListingDtoToJson(this);
}
