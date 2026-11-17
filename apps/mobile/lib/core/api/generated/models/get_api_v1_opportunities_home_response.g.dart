// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_opportunities_home_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1OpportunitiesHomeResponse _$GetApiV1OpportunitiesHomeResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1OpportunitiesHomeResponse(
  data: OpportunitiesHomeDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1OpportunitiesHomeResponseToJson(
  GetApiV1OpportunitiesHomeResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
