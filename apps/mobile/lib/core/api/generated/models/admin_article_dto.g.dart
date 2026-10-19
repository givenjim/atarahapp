// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_article_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminArticleDto _$AdminArticleDtoFromJson(Map<String, dynamic> json) =>
    AdminArticleDto(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      authorName: json['authorName'] as String,
      status: AdminArticleDtoStatus.fromJson(json['status'] as String),
      source: AdminArticleDtoSource.fromJson(json['source'] as String),
      scheduled: json['scheduled'] as bool,
      featured: json['featured'] as bool,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      summary: json['summary'] as String,
      readMinutes: json['readMinutes'] as num,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      blocks: (json['blocks'] as List<dynamic>)
          .map((e) => AdminArticleBlockDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      sourceLabel: json['sourceLabel'] as String?,
      heroMediaId: json['heroMediaId'] as String?,
      heroUrl: json['heroUrl'] as String?,
    );

Map<String, dynamic> _$AdminArticleDtoToJson(AdminArticleDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'title': instance.title,
      'authorName': instance.authorName,
      'status': instance.status,
      'source': instance.source,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'scheduled': instance.scheduled,
      'featured': instance.featured,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'summary': instance.summary,
      'sourceLabel': instance.sourceLabel,
      'readMinutes': instance.readMinutes,
      'tags': instance.tags,
      'heroMediaId': instance.heroMediaId,
      'heroUrl': instance.heroUrl,
      'blocks': instance.blocks,
      'createdAt': instance.createdAt.toIso8601String(),
    };
