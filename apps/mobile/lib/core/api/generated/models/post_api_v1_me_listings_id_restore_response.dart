// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'my_listing_dto.dart';

part 'post_api_v1_me_listings_id_restore_response.g.dart';

@JsonSerializable()
class PostApiV1MeListingsIdRestoreResponse {
  const PostApiV1MeListingsIdRestoreResponse({
    required this.data,
    this.meta,
  });
  
  factory PostApiV1MeListingsIdRestoreResponse.fromJson(Map<String, Object?> json) => _$PostApiV1MeListingsIdRestoreResponseFromJson(json);
  
  final MyListingDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PostApiV1MeListingsIdRestoreResponseToJson(this);
}
