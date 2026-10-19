// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'creative_card_dto.dart';

part 'get_api_v1_creatives_response.g.dart';

@JsonSerializable()
class GetApiV1CreativesResponse {
  const GetApiV1CreativesResponse({required this.data, this.meta});

  factory GetApiV1CreativesResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1CreativesResponseFromJson(json);

  final List<CreativeCardDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1CreativesResponseToJson(this);
}
