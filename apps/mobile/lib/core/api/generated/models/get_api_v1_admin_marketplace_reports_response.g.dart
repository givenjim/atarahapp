// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_marketplace_reports_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminMarketplaceReportsResponse
_$GetApiV1AdminMarketplaceReportsResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1AdminMarketplaceReportsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => AdminListingReportDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1AdminMarketplaceReportsResponseToJson(
  GetApiV1AdminMarketplaceReportsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
