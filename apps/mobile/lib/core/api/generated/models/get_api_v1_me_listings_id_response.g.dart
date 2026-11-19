// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_me_listings_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1MeListingsIdResponse _$GetApiV1MeListingsIdResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1MeListingsIdResponse(
  data: MyListingDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1MeListingsIdResponseToJson(
  GetApiV1MeListingsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
