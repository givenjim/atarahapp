// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_preview_work_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CvPreviewWorkDto _$CvPreviewWorkDtoFromJson(Map<String, dynamic> json) =>
    CvPreviewWorkDto(
      title: json['title'] as String,
      role: json['role'] as String?,
      year: json['year'] as num?,
    );

Map<String, dynamic> _$CvPreviewWorkDtoToJson(CvPreviewWorkDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'role': instance.role,
      'year': instance.year,
    };
