// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_opportunities_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1OpportunitiesResponse _$GetApiV1OpportunitiesResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1OpportunitiesResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => OpportunityCardDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1OpportunitiesResponseToJson(
  GetApiV1OpportunitiesResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
