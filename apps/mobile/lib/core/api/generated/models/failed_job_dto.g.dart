// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'failed_job_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FailedJobDto _$FailedJobDtoFromJson(Map<String, dynamic> json) => FailedJobDto(
  id: json['id'] as String,
  name: json['name'] as String,
  failedReason: json['failedReason'] as String,
  attemptsMade: json['attemptsMade'] as num,
  failedAt: json['failedAt'] == null
      ? null
      : DateTime.parse(json['failedAt'] as String),
);

Map<String, dynamic> _$FailedJobDtoToJson(FailedJobDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'failedReason': instance.failedReason,
      'attemptsMade': instance.attemptsMade,
      'failedAt': instance.failedAt?.toIso8601String(),
    };
