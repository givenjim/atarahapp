// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_project_choice_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CvProjectChoiceDto _$CvProjectChoiceDtoFromJson(Map<String, dynamic> json) =>
    CvProjectChoiceDto(
      id: json['id'] as String,
      title: json['title'] as String,
      visibility: CvProjectChoiceDtoVisibility.fromJson(
        json['visibility'] as String,
      ),
      role: json['role'] as String?,
      year: json['year'] as num?,
    );

Map<String, dynamic> _$CvProjectChoiceDtoToJson(CvProjectChoiceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'role': instance.role,
      'year': instance.year,
      'visibility': instance.visibility,
    };
