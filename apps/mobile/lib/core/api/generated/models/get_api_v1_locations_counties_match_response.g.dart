// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_locations_counties_match_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1LocationsCountiesMatchResponse
_$GetApiV1LocationsCountiesMatchResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1LocationsCountiesMatchResponse(
      data: CountyMatchDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1LocationsCountiesMatchResponseToJson(
  GetApiV1LocationsCountiesMatchResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
