// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'my_listing_dto.dart';

part 'patch_api_v1_me_listings_id_response.g.dart';

@JsonSerializable()
class PatchApiV1MeListingsIdResponse {
  const PatchApiV1MeListingsIdResponse({
    required this.data,
    this.meta,
  });
  
  factory PatchApiV1MeListingsIdResponse.fromJson(Map<String, Object?> json) => _$PatchApiV1MeListingsIdResponseFromJson(json);
  
  final MyListingDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$PatchApiV1MeListingsIdResponseToJson(this);
}
