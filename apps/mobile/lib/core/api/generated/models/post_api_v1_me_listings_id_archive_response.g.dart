// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_listings_id_archive_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeListingsIdArchiveResponse
_$PostApiV1MeListingsIdArchiveResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1MeListingsIdArchiveResponse(
      data: MyListingDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1MeListingsIdArchiveResponseToJson(
  PostApiV1MeListingsIdArchiveResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
