// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_provider_opportunities_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1ProviderOpportunitiesResponse
_$PostApiV1ProviderOpportunitiesResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1ProviderOpportunitiesResponse(
      data: AdminOpportunityDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1ProviderOpportunitiesResponseToJson(
  PostApiV1ProviderOpportunitiesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
