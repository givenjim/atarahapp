// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'application_item_dto_status.dart';
import 'opportunity_card_dto.dart';
import 'tracking_state_dto.dart';

part 'application_item_dto.g.dart';

@JsonSerializable()
class ApplicationItemDto {
  const ApplicationItemDto({
    required this.opportunity,
    required this.tracking,
    required this.status,
    required this.metaLine,
  });
  
  factory ApplicationItemDto.fromJson(Map<String, Object?> json) => _$ApplicationItemDtoFromJson(json);
  
  final OpportunityCardDto opportunity;
  final TrackingStateDto tracking;
  final ApplicationItemDtoStatus status;

  /// Ready to show under the title: "Applied 12 Oct", "Awarded".
  final String metaLine;

  Map<String, Object?> toJson() => _$ApplicationItemDtoToJson(this);
}
