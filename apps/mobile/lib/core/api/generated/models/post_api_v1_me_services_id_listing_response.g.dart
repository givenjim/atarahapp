// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_services_id_listing_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeServicesIdListingResponse
_$PostApiV1MeServicesIdListingResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1MeServicesIdListingResponse(
      data: MyListingDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1MeServicesIdListingResponseToJson(
  PostApiV1MeServicesIdListingResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
