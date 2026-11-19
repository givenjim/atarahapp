// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'opportunity_card_dto.dart';
import 'opportunity_category_count_dto.dart';

part 'opportunities_home_dto.g.dart';

@JsonSerializable()
class OpportunitiesHomeDto {
  const OpportunitiesHomeDto({
    required this.savedCount,
    required this.categories,
    required this.featured,
    required this.closingSoon,
    required this.recent,
  });
  
  factory OpportunitiesHomeDto.fromJson(Map<String, Object?> json) => _$OpportunitiesHomeDtoFromJson(json);
  
  /// Saved list size, for the badge on the saved button.
  final num savedCount;
  final List<OpportunityCategoryCountDto> categories;
  final List<OpportunityCardDto> featured;
  final List<OpportunityCardDto> closingSoon;
  final List<OpportunityCardDto> recent;

  Map<String, Object?> toJson() => _$OpportunitiesHomeDtoToJson(this);
}
