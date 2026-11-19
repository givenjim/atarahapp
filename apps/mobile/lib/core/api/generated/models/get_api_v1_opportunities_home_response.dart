// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'opportunities_home_dto.dart';

part 'get_api_v1_opportunities_home_response.g.dart';

@JsonSerializable()
class GetApiV1OpportunitiesHomeResponse {
  const GetApiV1OpportunitiesHomeResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1OpportunitiesHomeResponse.fromJson(Map<String, Object?> json) => _$GetApiV1OpportunitiesHomeResponseFromJson(json);
  
  final OpportunitiesHomeDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1OpportunitiesHomeResponseToJson(this);
}
