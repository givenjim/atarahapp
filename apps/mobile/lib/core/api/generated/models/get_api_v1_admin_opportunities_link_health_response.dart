// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'link_health_item_dto.dart';

part 'get_api_v1_admin_opportunities_link_health_response.g.dart';

@JsonSerializable()
class GetApiV1AdminOpportunitiesLinkHealthResponse {
  const GetApiV1AdminOpportunitiesLinkHealthResponse({
    required this.data,
    this.meta,
  });

  factory GetApiV1AdminOpportunitiesLinkHealthResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetApiV1AdminOpportunitiesLinkHealthResponseFromJson(json);

  final List<LinkHealthItemDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$GetApiV1AdminOpportunitiesLinkHealthResponseToJson(this);
}
