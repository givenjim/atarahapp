// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'my_listing_dto.dart';

part 'post_api_v1_me_listings_id_withdraw_response.g.dart';

@JsonSerializable()
class PostApiV1MeListingsIdWithdrawResponse {
  const PostApiV1MeListingsIdWithdrawResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1MeListingsIdWithdrawResponse.fromJson(Map<String, Object?> json) => _$PostApiV1MeListingsIdWithdrawResponseFromJson(json);
  
  final MyListingDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MeListingsIdWithdrawResponseToJson(this);
}
