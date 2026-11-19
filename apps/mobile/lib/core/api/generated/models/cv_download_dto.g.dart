// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_download_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CvDownloadDto _$CvDownloadDtoFromJson(Map<String, dynamic> json) =>
    CvDownloadDto(
      url: json['url'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$CvDownloadDtoToJson(CvDownloadDto instance) =>
    <String, dynamic>{
      'url': instance.url,
      'expiresAt': instance.expiresAt.toIso8601String(),
    };
