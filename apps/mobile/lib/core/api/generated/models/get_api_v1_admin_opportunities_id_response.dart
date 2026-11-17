// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_opportunity_dto.dart';

part 'get_api_v1_admin_opportunities_id_response.g.dart';

@JsonSerializable()
class GetApiV1AdminOpportunitiesIdResponse {
  const GetApiV1AdminOpportunitiesIdResponse({required this.data, this.meta});

  factory GetApiV1AdminOpportunitiesIdResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1AdminOpportunitiesIdResponseFromJson(json);

  final AdminOpportunityDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1AdminOpportunitiesIdResponseToJson(this);
}
