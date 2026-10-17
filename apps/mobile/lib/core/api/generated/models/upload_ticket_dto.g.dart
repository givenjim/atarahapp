// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_ticket_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadTicketDto _$UploadTicketDtoFromJson(Map<String, dynamic> json) =>
    UploadTicketDto(
      id: json['id'] as String,
      uploadUrl: json['uploadUrl'] as String,
      method: UploadTicketDtoMethod.fromJson(json['method'] as String),
      headers: Map<String, String>.from(json['headers'] as Map),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$UploadTicketDtoToJson(UploadTicketDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uploadUrl': instance.uploadUrl,
      'method': instance.method,
      'headers': instance.headers,
      'expiresAt': instance.expiresAt.toIso8601String(),
    };
