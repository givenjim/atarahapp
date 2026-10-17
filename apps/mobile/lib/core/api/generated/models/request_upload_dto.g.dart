// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_upload_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestUploadDto _$RequestUploadDtoFromJson(Map<String, dynamic> json) =>
    RequestUploadDto(
      kind: RequestUploadDtoKind.fromJson(json['kind'] as String),
      mimeType: json['mimeType'] as String,
      sizeBytes: json['sizeBytes'] as num,
      visibility: RequestUploadDtoVisibility.fromJson(
        json['visibility'] as String,
      ),
    );

Map<String, dynamic> _$RequestUploadDtoToJson(RequestUploadDto instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'mimeType': instance.mimeType,
      'sizeBytes': instance.sizeBytes,
      'visibility': instance.visibility,
    };
