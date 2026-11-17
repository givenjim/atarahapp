// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_opportunities_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminOpportunitiesResponse _$GetApiV1AdminOpportunitiesResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminOpportunitiesResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => AdminOpportunityDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminOpportunitiesResponseToJson(
  GetApiV1AdminOpportunitiesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
