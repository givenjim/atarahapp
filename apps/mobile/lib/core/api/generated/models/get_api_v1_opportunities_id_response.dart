// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'opportunity_dto.dart';

part 'get_api_v1_opportunities_id_response.g.dart';

@JsonSerializable()
class GetApiV1OpportunitiesIdResponse {
  const GetApiV1OpportunitiesIdResponse({required this.data, this.meta});

  factory GetApiV1OpportunitiesIdResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1OpportunitiesIdResponseFromJson(json);

  final OpportunityDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1OpportunitiesIdResponseToJson(this);
}
