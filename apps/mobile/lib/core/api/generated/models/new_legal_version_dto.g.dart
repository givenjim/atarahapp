// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_legal_version_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewLegalVersionDto _$NewLegalVersionDtoFromJson(Map<String, dynamic> json) =>
    NewLegalVersionDto(
      type: LegalDocumentType.fromJson(json['type'] as String),
      version: json['version'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
    );

Map<String, dynamic> _$NewLegalVersionDtoToJson(NewLegalVersionDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'version': instance.version,
      'title': instance.title,
      'body': instance.body,
    };
