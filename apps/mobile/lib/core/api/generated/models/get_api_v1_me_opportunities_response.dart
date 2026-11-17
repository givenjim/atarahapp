// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'my_opportunity_dto.dart';

part 'get_api_v1_me_opportunities_response.g.dart';

@JsonSerializable()
class GetApiV1MeOpportunitiesResponse {
  const GetApiV1MeOpportunitiesResponse({required this.data, this.meta});

  factory GetApiV1MeOpportunitiesResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1MeOpportunitiesResponseFromJson(json);

  final List<MyOpportunityDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1MeOpportunitiesResponseToJson(this);
}
