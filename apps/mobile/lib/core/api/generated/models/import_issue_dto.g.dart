// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_issue_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportIssueDto _$ImportIssueDtoFromJson(Map<String, dynamic> json) =>
    ImportIssueDto(
      line: json['line'] as num,
      message: json['message'] as String,
      column: json['column'] as String?,
    );

Map<String, dynamic> _$ImportIssueDtoToJson(ImportIssueDto instance) =>
    <String, dynamic>{
      'line': instance.line,
      'column': instance.column,
      'message': instance.message,
    };
