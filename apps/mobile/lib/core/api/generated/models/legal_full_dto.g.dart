// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legal_full_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LegalFullDto _$LegalFullDtoFromJson(Map<String, dynamic> json) => LegalFullDto(
  type: LegalDocumentType.fromJson(json['type'] as String),
  title: json['title'] as String,
  version: json['version'] as String,
  isDraft: json['isDraft'] as bool,
  body: json['body'] as String,
  effectiveAt: json['effectiveAt'] == null
      ? null
      : DateTime.parse(json['effectiveAt'] as String),
  draftLabel: json['draftLabel'] as String?,
);

Map<String, dynamic> _$LegalFullDtoToJson(LegalFullDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'version': instance.version,
      'effectiveAt': instance.effectiveAt?.toIso8601String(),
      'isDraft': instance.isDraft,
      'draftLabel': instance.draftLabel,
      'body': instance.body,
    };
