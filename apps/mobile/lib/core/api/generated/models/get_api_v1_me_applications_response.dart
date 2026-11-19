// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'application_item_dto.dart';

part 'get_api_v1_me_applications_response.g.dart';

@JsonSerializable()
class GetApiV1MeApplicationsResponse {
  const GetApiV1MeApplicationsResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1MeApplicationsResponse.fromJson(Map<String, Object?> json) => _$GetApiV1MeApplicationsResponseFromJson(json);
  
  final List<ApplicationItemDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1MeApplicationsResponseToJson(this);
}
