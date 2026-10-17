// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'audit_log_entry_dto.dart';

part 'get_api_v1_admin_audit_logs_response.g.dart';

@JsonSerializable()
class GetApiV1AdminAuditLogsResponse {
  const GetApiV1AdminAuditLogsResponse({required this.data, this.meta});

  factory GetApiV1AdminAuditLogsResponse.fromJson(Map<String, Object?> json) =>
      _$GetApiV1AdminAuditLogsResponseFromJson(json);

  final List<AuditLogEntryDto> data;
  final dynamic meta;

  Map<String, Object?> toJson() => _$GetApiV1AdminAuditLogsResponseToJson(this);
}
