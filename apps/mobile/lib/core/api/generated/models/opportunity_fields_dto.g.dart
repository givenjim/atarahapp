// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opportunity_fields_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpportunityFieldsDto _$OpportunityFieldsDtoFromJson(
  Map<String, dynamic> json,
) => OpportunityFieldsDto(
  title: json['title'] as String,
  providerId: json['providerId'] as String,
  type: OpportunityType.fromJson(json['type'] as String),
  summary: json['summary'] as String,
  about: json['about'] as String?,
  requirements: (json['requirements'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  benefits: (json['benefits'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  valueMin: json['valueMin'] as num?,
  valueMax: json['valueMax'] as num?,
  valueCurrency: json['valueCurrency'] as String?,
  valueText: json['valueText'] as String?,
  deadlineAt: json['deadlineAt'] == null
      ? null
      : DateTime.parse(json['deadlineAt'] as String),
  countyId: json['countyId'],
  workMode: json['workMode'] == null
      ? null
      : WorkMode.fromJson(json['workMode'] as String),
  applicationMethod: json['applicationMethod'] == null
      ? null
      : OpportunityFieldsDtoApplicationMethod.fromJson(
          json['applicationMethod'] as String,
        ),
  applicationUrl: json['applicationUrl'] as String?,
  applicationEmail: json['applicationEmail'] as String?,
  sourceUrl: json['sourceUrl'] as String?,
  disciplineIds: (json['disciplineIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  rules: (json['rules'] as List<dynamic>?)
      ?.map((e) => RuleInputDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OpportunityFieldsDtoToJson(
  OpportunityFieldsDto instance,
) => <String, dynamic>{
  'title': instance.title,
  'providerId': instance.providerId,
  'type': instance.type,
  'summary': instance.summary,
  'about': instance.about,
  'requirements': instance.requirements,
  'benefits': instance.benefits,
  'valueMin': instance.valueMin,
  'valueMax': instance.valueMax,
  'valueCurrency': instance.valueCurrency,
  'valueText': instance.valueText,
  'deadlineAt': instance.deadlineAt?.toIso8601String(),
  'countyId': instance.countyId,
  'workMode': instance.workMode,
  'applicationMethod': instance.applicationMethod,
  'applicationUrl': instance.applicationUrl,
  'applicationEmail': instance.applicationEmail,
  'sourceUrl': instance.sourceUrl,
  'disciplineIds': instance.disciplineIds,
  'rules': instance.rules,
};
