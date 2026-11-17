// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_opportunities_id_set_trust_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminOpportunitiesIdSetTrustResponse
_$PostApiV1AdminOpportunitiesIdSetTrustResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminOpportunitiesIdSetTrustResponse(
  data: AdminOpportunityDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminOpportunitiesIdSetTrustResponseToJson(
  PostApiV1AdminOpportunitiesIdSetTrustResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
