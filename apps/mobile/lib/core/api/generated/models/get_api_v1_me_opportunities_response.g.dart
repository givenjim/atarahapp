// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_opportunities_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeOpportunitiesResponse _$GetApiV1MeOpportunitiesResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeOpportunitiesResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => MyOpportunityDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeOpportunitiesResponseToJson(
  GetApiV1MeOpportunitiesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
