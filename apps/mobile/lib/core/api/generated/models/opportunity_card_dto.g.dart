// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opportunity_card_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpportunityCardDto _$OpportunityCardDtoFromJson(Map<String, dynamic> json) =>
    OpportunityCardDto(
      id: json['id'] as String,
      slug: json['slug'] as String,
      type: OpportunityType.fromJson(json['type'] as String),
      title: json['title'] as String,
      summary: json['summary'] as String,
      trust: OpportunityTrust.fromJson(json['trust'] as String),
      provider: OpportunityProviderLiteDto.fromJson(
        json['provider'] as Map<String, dynamic>,
      ),
      workMode: WorkMode.fromJson(json['workMode'] as String),
      featured: json['featured'] as bool,
      saved: json['saved'] as bool,
      closed: json['closed'] as bool,
      valueLabel: json['valueLabel'] as String?,
      deadlineAt: json['deadlineAt'] == null
          ? null
          : DateTime.parse(json['deadlineAt'] as String),
      daysLeft: json['daysLeft'] as num?,
      urgency: json['urgency'] == null
          ? null
          : OpportunityCardDtoUrgency.fromJson(json['urgency'] as String),
      locationLabel: json['locationLabel'] as String?,
      tracking: json['tracking'] == null
          ? null
          : TrackingStateDto.fromJson(json['tracking'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpportunityCardDtoToJson(OpportunityCardDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'type': instance.type,
      'title': instance.title,
      'summary': instance.summary,
      'trust': instance.trust,
      'provider': instance.provider,
      'valueLabel': instance.valueLabel,
      'deadlineAt': instance.deadlineAt?.toIso8601String(),
      'daysLeft': instance.daysLeft,
      'urgency': instance.urgency,
      'workMode': instance.workMode,
      'locationLabel': instance.locationLabel,
      'featured': instance.featured,
      'saved': instance.saved,
      'tracking': instance.tracking,
      'closed': instance.closed,
    };
