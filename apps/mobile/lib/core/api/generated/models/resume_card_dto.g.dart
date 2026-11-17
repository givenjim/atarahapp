// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resume_card_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResumeCardDto _$ResumeCardDtoFromJson(Map<String, dynamic> json) =>
    ResumeCardDto(
      kind: ResumeCardDtoKind.fromJson(json['kind'] as String),
      title: json['title'] as String,
      path: json['path'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      subtitle: json['subtitle'] as String?,
      progressPercent: json['progressPercent'] as num?,
    );

Map<String, dynamic> _$ResumeCardDtoToJson(ResumeCardDto instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'progressPercent': instance.progressPercent,
      'path': instance.path,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
