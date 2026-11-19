// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'my_application_dto.dart';

part 'get_api_v1_me_mentor_application_response.g.dart';

@JsonSerializable()
class GetApiV1MeMentorApplicationResponse {
  const GetApiV1MeMentorApplicationResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1MeMentorApplicationResponse.fromJson(Map<String, Object?> json) => _$GetApiV1MeMentorApplicationResponseFromJson(json);
  
  final MyApplicationDto data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeMentorApplicationResponseToJson(this);
}
