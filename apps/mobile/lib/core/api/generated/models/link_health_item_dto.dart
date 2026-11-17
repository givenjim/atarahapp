// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'link_health_item_dto_link_status.dart';
import 'opportunity_status.dart';

part 'link_health_item_dto.g.dart';

@JsonSerializable()
class LinkHealthItemDto {
  const LinkHealthItemDto({
    required this.opportunityId,
    required this.title,
    required this.provider,
    required this.status,
    required this.linkStatus,
    this.applicationUrl,
    this.httpStatus,
    this.error,
    this.checkedAt,
  });

  factory LinkHealthItemDto.fromJson(Map<String, Object?> json) =>
      _$LinkHealthItemDtoFromJson(json);

  final String opportunityId;
  final String title;
  final String provider;
  final OpportunityStatus status;
  final String? applicationUrl;
  final LinkHealthItemDtoLinkStatus linkStatus;
  final num? httpStatus;
  final String? error;
  final DateTime? checkedAt;

  Map<String, Object?> toJson() => _$LinkHealthItemDtoToJson(this);
}
