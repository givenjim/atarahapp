// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_api_v1_admin_audit_logs_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetApiV1AdminAuditLogsResponse _$GetApiV1AdminAuditLogsResponseFromJson(
  Map<String, dynamic> json,
) => GetApiV1AdminAuditLogsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => AuditLogEntryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'],
);

Map<String, dynamic> _$GetApiV1AdminAuditLogsResponseToJson(
  GetApiV1AdminAuditLogsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
