// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'proposed_session_type_dto.g.dart';

@JsonSerializable()
class ProposedSessionTypeDto {
  const ProposedSessionTypeDto({
    required this.name,
    required this.durationMinutes,
    required this.priceMinor,
    this.sessionCount = 1,
    this.description,
  });
  
  factory ProposedSessionTypeDto.fromJson(Map<String, Object?> json) => _$ProposedSessionTypeDtoFromJson(json);
  
  final String name;
  final String? description;
  final num durationMinutes;

  /// Minor units (KES cents). 150000 is KES 1,500.
  final num priceMinor;
  final num sessionCount;

  Map<String, Object?> toJson() => _$ProposedSessionTypeDtoToJson(this);
}
