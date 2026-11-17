// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_opportunity_providers_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminOpportunityProvidersResponse
_$GetApiV1AdminOpportunityProvidersResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminOpportunityProvidersResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => AdminProviderDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminOpportunityProvidersResponseToJson(
  GetApiV1AdminOpportunityProvidersResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
