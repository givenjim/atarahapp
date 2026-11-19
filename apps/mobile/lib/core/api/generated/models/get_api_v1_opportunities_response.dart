// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'opportunity_card_dto.dart';

part 'get_api_v1_opportunities_response.g.dart';

@JsonSerializable()
class GetApiV1OpportunitiesResponse {
  const GetApiV1OpportunitiesResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1OpportunitiesResponse.fromJson(Map<String, Object?> json) => _$GetApiV1OpportunitiesResponseFromJson(json);
  
  final List<OpportunityCardDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1OpportunitiesResponseToJson(this);
}
