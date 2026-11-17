// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_legal_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminLegalDto _$AdminLegalDtoFromJson(Map<String, dynamic> json) =>
    AdminLegalDto(
      type: LegalDocumentType.fromJson(json['type'] as String),
      title: json['title'] as String,
      version: json['version'] as String,
      isDraft: json['isDraft'] as bool,
      body: json['body'] as String,
      id: json['id'] as String,
      status: AdminLegalDtoStatus.fromJson(json['status'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      effectiveAt: json['effectiveAt'] == null
          ? null
          : DateTime.parse(json['effectiveAt'] as String),
      draftLabel: json['draftLabel'] as String?,
    );

Map<String, dynamic> _$AdminLegalDtoToJson(AdminLegalDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'version': instance.version,
      'effectiveAt': instance.effectiveAt?.toIso8601String(),
      'isDraft': instance.isDraft,
      'draftLabel': instance.draftLabel,
      'body': instance.body,
      'id': instance.id,
      'status': instance.status,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
