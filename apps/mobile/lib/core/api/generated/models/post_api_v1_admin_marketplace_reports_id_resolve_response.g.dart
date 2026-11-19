// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_marketplace_reports_id_resolve_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminMarketplaceReportsIdResolveResponse
_$PostApiV1AdminMarketplaceReportsIdResolveResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminMarketplaceReportsIdResolveResponse(
  data: AdminListingReportDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminMarketplaceReportsIdResolveResponseToJson(
  PostApiV1AdminMarketplaceReportsIdResolveResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
