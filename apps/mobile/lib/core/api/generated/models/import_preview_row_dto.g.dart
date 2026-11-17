// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_preview_row_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportPreviewRowDto _$ImportPreviewRowDtoFromJson(Map<String, dynamic> json) =>
    ImportPreviewRowDto(
      line: json['line'] as num,
      title: json['title'] as String,
      provider: json['provider'] as String,
      type: OpportunityType.fromJson(json['type'] as String),
      providerExists: json['providerExists'] as bool,
      deadlineAt: json['deadlineAt'] == null
          ? null
          : DateTime.parse(json['deadlineAt'] as String),
    );

Map<String, dynamic> _$ImportPreviewRowDtoToJson(
  ImportPreviewRowDto instance,
) => <String, dynamic>{
  'line': instance.line,
  'title': instance.title,
  'provider': instance.provider,
  'type': instance.type,
  'deadlineAt': instance.deadlineAt?.toIso8601String(),
  'providerExists': instance.providerExists,
};
