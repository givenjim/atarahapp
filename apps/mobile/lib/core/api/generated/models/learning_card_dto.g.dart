// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_card_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LearningCardDto _$LearningCardDtoFromJson(Map<String, dynamic> json) =>
    LearningCardDto(
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
      lessonCount: json['lessonCount'] as num?,
      providerName: json['providerName'] as String?,
      coverUrl: json['coverUrl'] as String?,
      progress: json['progress'] == null
          ? null
          : LearningItemProgressDto.fromJson(
              json['progress'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$LearningCardDtoToJson(LearningCardDto instance) =>
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
    };
