// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'growth_dto.dart';

part 'get_api_v1_me_growth_response.g.dart';

@JsonSerializable()
class GetApiV1MeGrowthResponse {
  const GetApiV1MeGrowthResponse({required this.data, this.meta});

  factory GetApiV1MeGrowthResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1MeGrowthResponseFromJson(json);

  final GrowthDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeGrowthResponseToJson(this);
}
