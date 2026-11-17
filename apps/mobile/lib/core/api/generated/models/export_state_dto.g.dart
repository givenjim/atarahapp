// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_state_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportStateDto _$ExportStateDtoFromJson(Map<String, dynamic> json) =>
    ExportStateDto(
      status: ExportStateDtoStatus.fromJson(json['status'] as String),
      id: json['id'] as String?,
      requestedAt: json['requestedAt'] == null
          ? null
          : DateTime.parse(json['requestedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      downloadUrl: json['downloadUrl'] as String?,
      nextAllowedAt: json['nextAllowedAt'] == null
          ? null
          : DateTime.parse(json['nextAllowedAt'] as String),
    );

Map<String, dynamic> _$ExportStateDtoToJson(ExportStateDto instance) =>
    <String, dynamic>{
      'status': instance.status,
      'id': instance.id,
      'requestedAt': instance.requestedAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'downloadUrl': instance.downloadUrl,
      'nextAllowedAt': instance.nextAllowedAt?.toIso8601String(),
    };
