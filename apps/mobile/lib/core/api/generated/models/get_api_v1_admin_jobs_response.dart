// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'queue_counts_dto.dart';

part 'get_api_v1_admin_jobs_response.g.dart';

@JsonSerializable()
class GetApiV1AdminJobsResponse {
  const GetApiV1AdminJobsResponse({required this.data, this.meta});

  factory GetApiV1AdminJobsResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1AdminJobsResponseFromJson(json);

  final List<QueueCountsDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminJobsResponseToJson(this);
}
