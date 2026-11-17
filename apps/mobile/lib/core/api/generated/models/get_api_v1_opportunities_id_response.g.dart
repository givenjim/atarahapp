// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_opportunities_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1OpportunitiesIdResponse _$GetApiV1OpportunitiesIdResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1OpportunitiesIdResponse(
  data: OpportunityDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1OpportunitiesIdResponseToJson(
  GetApiV1OpportunitiesIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
