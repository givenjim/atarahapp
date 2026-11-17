// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_provider_dto.dart';

part 'post_api_v1_admin_opportunity_providers_id_verify_response.g.dart';

@JsonSerializable()
class PostApiV1AdminOpportunityProvidersIdVerifyResponse {
  const PostApiV1AdminOpportunityProvidersIdVerifyResponse({
    required this.data,
    this.meta,
  });

  factory PostApiV1AdminOpportunityProvidersIdVerifyResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostApiV1AdminOpportunityProvidersIdVerifyResponseFromJson(json);

  final AdminProviderDto data;
  final dynamic meta;

  Map<String, Object?> toJson() =>
      _$PostApiV1AdminOpportunityProvidersIdVerifyResponseToJson(this);
}
