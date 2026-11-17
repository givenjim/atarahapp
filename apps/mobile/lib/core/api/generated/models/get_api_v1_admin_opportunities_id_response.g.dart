// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_opportunities_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminOpportunitiesIdResponse
_$GetApiV1AdminOpportunitiesIdResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1AdminOpportunitiesIdResponse(
      data: AdminOpportunityDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1AdminOpportunitiesIdResponseToJson(
  GetApiV1AdminOpportunitiesIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
