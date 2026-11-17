// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_report_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportReportDto _$ImportReportDtoFromJson(Map<String, dynamic> json) =>
    ImportReportDto(
      totalCount: json['totalCount'] as num,
      validCount: json['validCount'] as num,
      issues: (json['issues'] as List<dynamic>)
          .map((e) => ImportIssueDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      preview: (json['preview'] as List<dynamic>)
          .map((e) => ImportPreviewRowDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ImportReportDtoToJson(ImportReportDto instance) =>
    <String, dynamic>{
      'totalCount': instance.totalCount,
      'validCount': instance.validCount,
      'issues': instance.issues,
      'preview': instance.preview,
    };
