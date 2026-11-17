// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityDto _$ActivityDtoFromJson(Map<String, dynamic> json) => ActivityDto(
  resume: (json['resume'] as List<dynamic>)
      .map((e) => ResumeCardDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  counts: ActivityCountsDto.fromJson(json['counts'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ActivityDtoToJson(ActivityDto instance) =>
    <String, dynamic>{'resume': instance.resume, 'counts': instance.counts};
