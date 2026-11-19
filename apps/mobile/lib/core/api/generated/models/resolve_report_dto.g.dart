// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resolve_report_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResolveReportDto _$ResolveReportDtoFromJson(Map<String, dynamic> json) =>
    ResolveReportDto(
      action: ResolveReportDtoAction.fromJson(json['action'] as String),
      note: json['note'] as String,
    );

Map<String, dynamic> _$ResolveReportDtoToJson(ResolveReportDto instance) =>
    <String, dynamic>{'action': instance.action, 'note': instance.note};
