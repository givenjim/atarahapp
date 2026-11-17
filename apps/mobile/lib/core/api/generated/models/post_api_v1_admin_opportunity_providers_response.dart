// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_provider_dto.dart';

part 'post_api_v1_admin_opportunity_providers_response.g.dart';

@JsonSerializable()
class PostApiV1AdminOpportunityProvidersResponse {
  const PostApiV1AdminOpportunityProvidersResponse({
    required this.data,
    this.meta,
  });

  factory PostApiV1AdminOpportunityProvidersResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminOpportunityProvidersResponseFromJson(json);

  final AdminProviderDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminOpportunityProvidersResponseToJson(this);
}
