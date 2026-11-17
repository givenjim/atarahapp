// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_admin_opportunities_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1AdminOpportunitiesIdResponse
_$PatchApiV1AdminOpportunitiesIdResponseFromJson(Map<String, dynamic> json) =>
    PatchApiV1AdminOpportunitiesIdResponse(
      data: AdminOpportunityDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PatchApiV1AdminOpportunitiesIdResponseToJson(
  PatchApiV1AdminOpportunitiesIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
