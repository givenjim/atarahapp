// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_provider_opportunities_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1ProviderOpportunitiesResponse
_$GetApiV1ProviderOpportunitiesResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1ProviderOpportunitiesResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => AdminOpportunityDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1ProviderOpportunitiesResponseToJson(
  GetApiV1ProviderOpportunitiesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
