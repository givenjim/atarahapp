// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_opportunities_link_health_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminOpportunitiesLinkHealthResponse
_$GetApiV1AdminOpportunitiesLinkHealthResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminOpportunitiesLinkHealthResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => LinkHealthItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminOpportunitiesLinkHealthResponseToJson(
  GetApiV1AdminOpportunitiesLinkHealthResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
