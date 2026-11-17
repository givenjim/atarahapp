// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_jobs_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminJobsResponse _$GetApiV1AdminJobsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminJobsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => QueueCountsDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminJobsResponseToJson(
  GetApiV1AdminJobsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
