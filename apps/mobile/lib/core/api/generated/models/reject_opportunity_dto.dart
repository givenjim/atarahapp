// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'reject_opportunity_dto.g.dart';

@JsonSerializable()
class RejectOpportunityDto {
  const RejectOpportunityDto({
    required this.reason,
  });
  
  factory RejectOpportunityDto.fromJson(Map<String, Object?> json) => _$RejectOpportunityDtoFromJson(json);
  
  /// Told to the provider.
  final String reason;

  Map<String, Object?> toJson() => _$RejectOpportunityDtoToJson(this);
}
