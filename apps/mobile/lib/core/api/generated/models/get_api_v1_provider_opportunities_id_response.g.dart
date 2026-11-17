// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_provider_opportunities_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1ProviderOpportunitiesIdResponse
_$GetApiV1ProviderOpportunitiesIdResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1ProviderOpportunitiesIdResponse(
      data: AdminOpportunityDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1ProviderOpportunitiesIdResponseToJson(
  GetApiV1ProviderOpportunitiesIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
