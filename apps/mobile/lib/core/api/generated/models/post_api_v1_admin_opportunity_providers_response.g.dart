// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_admin_opportunity_providers_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1AdminOpportunityProvidersResponse
_$PostApiV1AdminOpportunityProvidersResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1AdminOpportunityProvidersResponse(
  data: AdminProviderDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1AdminOpportunityProvidersResponseToJson(
  PostApiV1AdminOpportunityProvidersResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
