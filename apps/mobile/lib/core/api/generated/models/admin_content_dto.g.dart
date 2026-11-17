// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_content_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminContentDto _$AdminContentDtoFromJson(Map<String, dynamic> json) =>
    AdminContentDto(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      type: LearningContentType.fromJson(json['type'] as String),
      summary: json['summary'] as String,
      category: LearningCategoryRefDto.fromJson(
        json['category'] as Map<String, dynamic>,
      ),
      level: SkillLevel.fromJson(json['level'] as String),
      durationMinutes: json['durationMinutes'] as num,
      source: ContentSource.fromJson(json['source'] as String),
      delivery: ContentDelivery.fromJson(json['delivery'] as String),
      access: LearningAccess.fromJson(json['access'] as String),
      status: PublicationStatus.fromJson(json['status'] as String),
      featured: json['featured'] as bool,
      whatYouLearn: (json['whatYouLearn'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      disciplineIds: (json['disciplineIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      skillIds: (json['skillIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      linkStatus: AdminContentDtoLinkStatus.fromJson(
        json['linkStatus'] as String,
      ),
      lessons: (json['lessons'] as List<dynamic>)
          .map((e) => AdminLessonDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      enrolmentCount: json['enrolmentCount'] as num,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      providerName: json['providerName'] as String?,
      instructorUserId: json['instructorUserId'] as String?,
      externalUrl: json['externalUrl'] as String?,
      embedUrl: json['embedUrl'] as String?,
      coverMediaId: json['coverMediaId'] as String?,
      coverUrl: json['coverUrl'] as String?,
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      whoItsFor: json['whoItsFor'] as String?,
      lastCheckedAt: json['lastCheckedAt'] == null
          ? null
          : DateTime.parse(json['lastCheckedAt'] as String),
      sequential: json['sequential'] as bool?,
    );

Map<String, dynamic> _$AdminContentDtoToJson(AdminContentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'title': instance.title,
      'type': instance.type,
      'summary': instance.summary,
      'category': instance.category,
      'level': instance.level,
      'durationMinutes': instance.durationMinutes,
      'source': instance.source,
      'delivery': instance.delivery,
      'providerName': instance.providerName,
      'instructorUserId': instance.instructorUserId,
      'externalUrl': instance.externalUrl,
      'embedUrl': instance.embedUrl,
      'coverMediaId': instance.coverMediaId,
      'coverUrl': instance.coverUrl,
      'access': instance.access,
      'status': instance.status,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'featured': instance.featured,
      'whatYouLearn': instance.whatYouLearn,
      'whoItsFor': instance.whoItsFor,
      'disciplineIds': instance.disciplineIds,
      'skillIds': instance.skillIds,
      'linkStatus': instance.linkStatus,
      'lastCheckedAt': instance.lastCheckedAt?.toIso8601String(),
      'sequential': instance.sequential,
      'lessons': instance.lessons,
      'enrolmentCount': instance.enrolmentCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
