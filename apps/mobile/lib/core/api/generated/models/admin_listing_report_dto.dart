// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'listing_report_status.dart';
import 'listing_status.dart';
import 'report_reason.dart';

part 'admin_listing_report_dto.g.dart';

@JsonSerializable()
class AdminListingReportDto {
  const AdminListingReportDto({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.listingStatus,
    required this.sellerName,
    required this.reporterName,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.note,
    this.resolution,
  });
  
  factory AdminListingReportDto.fromJson(Map<String, Object?> json) => _$AdminListingReportDtoFromJson(json);
  
  final String id;
  final String listingId;
  final String listingTitle;
  final ListingStatus listingStatus;
  final String sellerName;
  final String reporterName;
  final ReportReason reason;
  final String? note;
  final ListingReportStatus status;
  final String? resolution;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$AdminListingReportDtoToJson(this);
}
