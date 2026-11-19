// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_listings_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeListingsResponse _$PostApiV1MeListingsResponseFromJson(
  Map<String, dynamic> json,
) => PostApiV1MeListingsResponse(
  data: MyListingDto.fromJson(json['data'] as Map<String, dynamic>),
  meta: json['meta'],
);

Map<String, dynamic> _$PostApiV1MeListingsResponseToJson(
  PostApiV1MeListingsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
