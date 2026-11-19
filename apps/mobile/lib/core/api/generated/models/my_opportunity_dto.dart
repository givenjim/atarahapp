// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'opportunity_card_dto.dart';
import 'tracking_state_dto.dart';

part 'my_opportunity_dto.g.dart';

@JsonSerializable()
class MyOpportunityDto {
  const MyOpportunityDto({
    required this.opportunity,
    required this.tracking,
  });
  
  factory MyOpportunityDto.fromJson(Map<String, Object?> json) => _$MyOpportunityDtoFromJson(json);
  
  final OpportunityCardDto opportunity;
  final TrackingStateDto tracking;

  Map<String, Object?> toJson() => _$MyOpportunityDtoToJson(this);
}
