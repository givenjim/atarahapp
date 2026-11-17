// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_opportunity_dto.dart';

part 'post_api_v1_admin_opportunities_id_reject_response.g.dart';

@JsonSerializable()
class PostApiV1AdminOpportunitiesIdRejectResponse {
  const PostApiV1AdminOpportunitiesIdRejectResponse({
    required this.data,
    this.meta,
  });

  factory PostApiV1AdminOpportunitiesIdRejectResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminOpportunitiesIdRejectResponseFromJson(json);

  final AdminOpportunityDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminOpportunitiesIdRejectResponseToJson(this);
}
