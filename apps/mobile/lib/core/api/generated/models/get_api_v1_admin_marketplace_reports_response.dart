// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_listing_report_dto.dart';

part 'get_api_v1_admin_marketplace_reports_response.g.dart';

@JsonSerializable()
class GetApiV1AdminMarketplaceReportsResponse {
  const GetApiV1AdminMarketplaceReportsResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1AdminMarketplaceReportsResponse.fromJson(Map<String, Object?> json) => _$GetApiV1AdminMarketplaceReportsResponseFromJson(json);
  
  final List<AdminListingReportDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminMarketplaceReportsResponseToJson(this);
}
