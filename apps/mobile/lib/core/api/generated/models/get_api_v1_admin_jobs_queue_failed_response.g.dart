// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_jobs_queue_failed_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminJobsQueueFailedResponse
_$GetApiV1AdminJobsQueueFailedResponseFromJson(Map<String, dynamic> json) =>
    GetApiV1AdminJobsQueueFailedResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => FailedJobDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'],
    );

Map<String, dynamic> _$GetApiV1AdminJobsQueueFailedResponseToJson(
  GetApiV1AdminJobsQueueFailedResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
