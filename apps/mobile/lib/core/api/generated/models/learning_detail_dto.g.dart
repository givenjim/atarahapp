// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LearningDetailDto _$LearningDetailDtoFromJson(Map<String, dynamic> json) =>
    LearningDetailDto(
      id: json['id'] as String,
      slug: json['slug'] as String,
      type: LearningContentType.fromJson(json['type'] as String),
      title: json['title'] as String,
      summary: json['summary'] as String,
      category: LearningCategoryRefDto.fromJson(
        json['category'] as Map<String, dynamic>,
      ),
      level: SkillLevel.fromJson(json['level'] as String),
      durationMinutes: json['durationMinutes'] as num,
      source: ContentSource.fromJson(json['source'] as String),
      delivery: ContentDelivery.fromJson(json['delivery'] as String),
      access: LearningAccess.fromJson(json['access'] as String),
      premiumLocked: json['premiumLocked'] as bool,
      featured: json['featured'] as bool,
      saved: json['saved'] as bool,
      whatYouLearn: (json['whatYouLearn'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      disciplines: (json['disciplines'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      skills: (json['skills'] as List<dynamic>)
          .map((e) => SkillRefDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      linkStatus: LearningDetailDtoLinkStatus.fromJson(
        json['linkStatus'] as String,
      ),
      shareUrl: json['shareUrl'] as String,
      lessonCount: json['lessonCount'] as num?,
      providerName: json['providerName'] as String?,
      coverUrl: json['coverUrl'] as String?,
      progress: json['progress'] == null
          ? null
          : LearningItemProgressDto.fromJson(
              json['progress'] as Map<String, dynamic>,
            ),
      whoItsFor: json['whoItsFor'] as String?,
      instructorName: json['instructorName'] as String?,
      course: json['course'] == null
          ? null
          : CourseInfoDto.fromJson(json['course'] as Map<String, dynamic>),
      externalUrl: json['externalUrl'] as String?,
      externalDomain: json['externalDomain'] as String?,
      embedUrl: json['embedUrl'] as String?,
      itemProgress: json['itemProgress'] == null
          ? null
          : LearningItemProgressDto.fromJson(
              json['itemProgress'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$LearningDetailDtoToJson(LearningDetailDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'type': instance.type,
      'title': instance.title,
      'summary': instance.summary,
      'category': instance.category,
      'level': instance.level,
      'durationMinutes': instance.durationMinutes,
      'lessonCount': instance.lessonCount,
      'source': instance.source,
      'delivery': instance.delivery,
      'providerName': instance.providerName,
      'coverUrl': instance.coverUrl,
      'access': instance.access,
      'premiumLocked': instance.premiumLocked,
      'featured': instance.featured,
      'saved': instance.saved,
      'progress': instance.progress,
      'whatYouLearn': instance.whatYouLearn,
      'whoItsFor': instance.whoItsFor,
      'instructorName': instance.instructorName,
      'disciplines': instance.disciplines,
      'skills': instance.skills,
      'course': instance.course,
      'externalUrl': instance.externalUrl,
      'externalDomain': instance.externalDomain,
      'embedUrl': instance.embedUrl,
      'linkStatus': instance.linkStatus,
      'itemProgress': instance.itemProgress,
      'shareUrl': instance.shareUrl,
    };
