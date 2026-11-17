// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_opportunity_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminOpportunityDto _$AdminOpportunityDtoFromJson(Map<String, dynamic> json) =>
    AdminOpportunityDto(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      type: OpportunityType.fromJson(json['type'] as String),
      status: OpportunityStatus.fromJson(json['status'] as String),
      trust: OpportunityTrust.fromJson(json['trust'] as String),
      provider: AdminProviderDto.fromJson(
        json['provider'] as Map<String, dynamic>,
      ),
      summary: json['summary'] as String,
      about: json['about'] as String,
      requirements: (json['requirements'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      benefits: (json['benefits'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      workMode: WorkMode.fromJson(json['workMode'] as String),
      applicationMethod: ApplicationMethod.fromJson(
        json['applicationMethod'] as String,
      ),
      linkStatus: AdminOpportunityDtoLinkStatus.fromJson(
        json['linkStatus'] as String,
      ),
      disciplineIds: (json['disciplineIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      rules: (json['rules'] as List<dynamic>)
          .map((e) => AdminRuleDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      trackerCount: json['trackerCount'] as num,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      valueMin: json['valueMin'] as num?,
      valueMax: json['valueMax'] as num?,
      valueCurrency: json['valueCurrency'] as String?,
      valueText: json['valueText'] as String?,
      deadlineAt: json['deadlineAt'] == null
          ? null
          : DateTime.parse(json['deadlineAt'] as String),
      countyId: json['countyId'] as String?,
      countyName: json['countyName'] as String?,
      applicationUrl: json['applicationUrl'] as String?,
      applicationEmail: json['applicationEmail'] as String?,
      applicationDomain: json['applicationDomain'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      featuredUntil: json['featuredUntil'] == null
          ? null
          : DateTime.parse(json['featuredUntil'] as String),
      lastCheckedAt: json['lastCheckedAt'] == null
          ? null
          : DateTime.parse(json['lastCheckedAt'] as String),
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
    );

Map<String, dynamic> _$AdminOpportunityDtoToJson(
  AdminOpportunityDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'title': instance.title,
  'type': instance.type,
  'status': instance.status,
  'trust': instance.trust,
  'provider': instance.provider,
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
  'countyName': instance.countyName,
  'workMode': instance.workMode,
  'applicationMethod': instance.applicationMethod,
  'applicationUrl': instance.applicationUrl,
  'applicationEmail': instance.applicationEmail,
  'applicationDomain': instance.applicationDomain,
  'sourceUrl': instance.sourceUrl,
  'featuredUntil': instance.featuredUntil?.toIso8601String(),
  'linkStatus': instance.linkStatus,
  'lastCheckedAt': instance.lastCheckedAt?.toIso8601String(),
  'publishedAt': instance.publishedAt?.toIso8601String(),
  'disciplineIds': instance.disciplineIds,
  'rules': instance.rules,
  'trackerCount': instance.trackerCount,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
