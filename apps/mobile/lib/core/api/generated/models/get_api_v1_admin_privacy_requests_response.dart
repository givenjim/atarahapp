// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'privacy_request_dto.dart';

part 'get_api_v1_admin_privacy_requests_response.g.dart';

@JsonSerializable()
class GetApiV1AdminPrivacyRequestsResponse {
  const GetApiV1AdminPrivacyRequestsResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1AdminPrivacyRequestsResponse.fromJson(Map<String, Object?> json) => _$GetApiV1AdminPrivacyRequestsResponseFromJson(json);
  
  final List<PrivacyRequestDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminPrivacyRequestsResponseToJson(this);
}
