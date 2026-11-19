// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_api_v1_me_listings_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchApiV1MeListingsIdResponse _$PatchApiV1MeListingsIdResponseFromJson(
  Map<String, dynamic> json,
) => PatchApiV1MeListingsIdResponse(
  data: MyListingDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PatchApiV1MeListingsIdResponseToJson(
  PatchApiV1MeListingsIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
