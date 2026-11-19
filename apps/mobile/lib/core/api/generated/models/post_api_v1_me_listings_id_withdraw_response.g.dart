// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_listings_id_withdraw_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeListingsIdWithdrawResponse
_$PostApiV1MeListingsIdWithdrawResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1MeListingsIdWithdrawResponse(
      data: MyListingDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1MeListingsIdWithdrawResponseToJson(
  PostApiV1MeListingsIdWithdrawResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
