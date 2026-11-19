// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_listing_report_dto.dart';

part 'post_api_v1_admin_marketplace_reports_id_resolve_response.g.dart';

@JsonSerializable()
class PostApiV1AdminMarketplaceReportsIdResolveResponse {
  const PostApiV1AdminMarketplaceReportsIdResolveResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1AdminMarketplaceReportsIdResolveResponse.fromJson(Map<String, Object?> json) => _$PostApiV1AdminMarketplaceReportsIdResolveResponseFromJson(json);
  
  final AdminListingReportDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1AdminMarketplaceReportsIdResolveResponseToJson(this);
}
