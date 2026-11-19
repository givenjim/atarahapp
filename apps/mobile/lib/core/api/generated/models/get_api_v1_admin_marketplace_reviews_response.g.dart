// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_marketplace_reviews_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminMarketplaceReviewsResponse
_$GetApiV1AdminMarketplaceReviewsResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1AdminMarketplaceReviewsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => AdminReviewDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1AdminMarketplaceReviewsResponseToJson(
  GetApiV1AdminMarketplaceReviewsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
