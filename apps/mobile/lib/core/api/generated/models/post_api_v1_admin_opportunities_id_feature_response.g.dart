// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_opportunities_id_feature_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminOpportunitiesIdFeatureResponse
_$PostApiV1AdminOpportunitiesIdFeatureResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminOpportunitiesIdFeatureResponse(
  data: AdminOpportunityDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminOpportunitiesIdFeatureResponseToJson(
  PostApiV1AdminOpportunitiesIdFeatureResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
