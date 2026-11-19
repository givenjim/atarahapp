// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'failed_job_dto.dart';

part 'get_api_v1_admin_jobs_queue_failed_response.g.dart';

@JsonSerializable()
class GetApiV1AdminJobsQueueFailedResponse {
  const GetApiV1AdminJobsQueueFailedResponse({
    required this.data,
    this.meta,
  });
  
  factory GetApiV1AdminJobsQueueFailedResponse.fromJson(Map<String, Object?> json) => _$GetApiV1AdminJobsQueueFailedResponseFromJson(json);
  
  final List<FailedJobDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminJobsQueueFailedResponseToJson(this);
}
