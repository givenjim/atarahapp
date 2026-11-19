// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_marketplace_reviews_id_restore_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminMarketplaceReviewsIdRestoreResponse
_$PostApiV1AdminMarketplaceReviewsIdRestoreResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminMarketplaceReviewsIdRestoreResponse(
  data: AdminReviewDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminMarketplaceReviewsIdRestoreResponseToJson(
  PostApiV1AdminMarketplaceReviewsIdRestoreResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
