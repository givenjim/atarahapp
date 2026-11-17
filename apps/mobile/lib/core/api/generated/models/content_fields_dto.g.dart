// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_fields_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentFieldsDto _$ContentFieldsDtoFromJson(Map<String, dynamic> json) =>
    ContentFieldsDto(
      title: json['title'] as String,
      type: LearningContentType.fromJson(json['type'] as String),
      summary: json['summary'] as String,
      categoryId: json['categoryId'] as String,
      level: json['level'] == null
          ? null
          : SkillLevel.fromJson(json['level'] as String),
      durationMinutes: json['durationMinutes'] as num?,
      source: json['source'] == null
          ? null
          : ContentSource.fromJson(json['source'] as String),
      delivery: json['delivery'] == null
          ? null
          : ContentDelivery.fromJson(json['delivery'] as String),
      providerName: json['providerName'] as String?,
      instructorUserId: json['instructorUserId'] as String?,
      externalUrl: json['externalUrl'] as String?,
      embedUrl: json['embedUrl'] as String?,
      coverMediaId: json['coverMediaId'] as String?,
      access: json['access'] == null
          ? null
          : LearningAccess.fromJson(json['access'] as String),
      featured: json['featured'] as bool?,
      whatYouLearn: (json['whatYouLearn'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      whoItsFor: json['whoItsFor'] as String?,
      disciplineIds: (json['disciplineIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      skillIds: (json['skillIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      sequential: json['sequential'] as bool?,
    );

Map<String, dynamic> _$ContentFieldsDtoToJson(ContentFieldsDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'type': instance.type,
      'summary': instance.summary,
      'categoryId': instance.categoryId,
      'level': instance.level,
      'durationMinutes': instance.durationMinutes,
      'source': instance.source,
      'delivery': instance.delivery,
      'providerName': instance.providerName,
      'instructorUserId': instance.instructorUserId,
      'externalUrl': instance.externalUrl,
      'embedUrl': instance.embedUrl,
      'coverMediaId': instance.coverMediaId,
      'access': instance.access,
      'featured': instance.featured,
      'whatYouLearn': instance.whatYouLearn,
      'whoItsFor': instance.whoItsFor,
      'disciplineIds': instance.disciplineIds,
      'skillIds': instance.skillIds,
      'sequential': instance.sequential,
    };
