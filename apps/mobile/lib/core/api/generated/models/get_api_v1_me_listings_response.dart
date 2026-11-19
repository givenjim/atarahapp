// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'my_listings_dto.dart';

part 'get_api_v1_me_listings_response.g.dart';

@JsonSerializable()
class GetApiV1MeListingsResponse {
  const GetApiV1MeListingsResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1MeListingsResponse.fromJson(Map<String, Object?> json) => _$GetApiV1MeListingsResponseFromJson(json);
  
  final MyListingsDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeListingsResponseToJson(this);
}
