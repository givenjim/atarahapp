// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'application_prefill_dto.dart';

part 'get_api_v1_me_mentor_application_prefill_response.g.dart';

@JsonSerializable()
class GetApiV1MeMentorApplicationPrefillResponse {
  const GetApiV1MeMentorApplicationPrefillResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1MeMentorApplicationPrefillResponse.fromJson(Map<String, Object?> json) => _$GetApiV1MeMentorApplicationPrefillResponseFromJson(json);
  
  final ApplicationPrefillDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeMentorApplicationPrefillResponseToJson(this);
}
