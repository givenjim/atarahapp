// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_listings_id_restore_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeListingsIdRestoreResponse
_$PostApiV1MeListingsIdRestoreResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1MeListingsIdRestoreResponse(
      data: MyListingDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1MeListingsIdRestoreResponseToJson(
  PostApiV1MeListingsIdRestoreResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
