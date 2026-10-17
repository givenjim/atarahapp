// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legal_document_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LegalDocumentDto _$LegalDocumentDtoFromJson(Map<String, dynamic> json) =>
    LegalDocumentDto(
      type: LegalDocumentDtoType.fromJson(json['type'] as String),
      version: json['version'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      isDraft: json['isDraft'] as bool,
    );

Map<String, dynamic> _$LegalDocumentDtoToJson(LegalDocumentDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'version': instance.version,
      'title': instance.title,
      'body': instance.body,
      'isDraft': instance.isDraft,
    };
