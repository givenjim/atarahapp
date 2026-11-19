// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_api_v1_me_listings_id_submit_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostApiV1MeListingsIdSubmitResponse
_$PostApiV1MeListingsIdSubmitResponseFromJson(Map<String, dynamic> json) =>
    PostApiV1MeListingsIdSubmitResponse(
      data: SubmitResultDto.fromJson(json['data'] as Map<String, dynamic>),
      meta: json['meta'],
    );

Map<String, dynamic> _$PostApiV1MeListingsIdSubmitResponseToJson(
  PostApiV1MeListingsIdSubmitResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
