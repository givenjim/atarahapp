// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legal_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LegalSummaryDto _$LegalSummaryDtoFromJson(Map<String, dynamic> json) =>
    LegalSummaryDto(
      type: LegalDocumentType.fromJson(json['type'] as String),
      title: json['title'] as String,
      version: json['version'] as String,
      isDraft: json['isDraft'] as bool,
      effectiveAt: json['effectiveAt'] == null
          ? null
          : DateTime.parse(json['effectiveAt'] as String),
      draftLabel: json['draftLabel'] as String?,
    );

Map<String, dynamic> _$LegalSummaryDtoToJson(LegalSummaryDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'version': instance.version,
      'effectiveAt': instance.effectiveAt?.toIso8601String(),
      'isDraft': instance.isDraft,
      'draftLabel': instance.draftLabel,
    };
