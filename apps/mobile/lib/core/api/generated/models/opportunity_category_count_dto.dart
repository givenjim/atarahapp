// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'opportunity_type.dart';

part 'opportunity_category_count_dto.g.dart';

@JsonSerializable()
class OpportunityCategoryCountDto {
  const OpportunityCategoryCountDto({
    required this.type,
    required this.count,
  });
  
  factory OpportunityCategoryCountDto.fromJson(Map<String, Object?> json) => _$OpportunityCategoryCountDtoFromJson(json);
  
  final OpportunityType type;
  final num count;

  Map<String, Object?> toJson() => _$OpportunityCategoryCountDtoToJson(this);
}
