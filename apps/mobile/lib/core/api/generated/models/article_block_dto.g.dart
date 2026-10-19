// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_block_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArticleBlockDto _$ArticleBlockDtoFromJson(Map<String, dynamic> json) =>
    ArticleBlockDto(
      type: ArticleBlockDtoType.fromJson(json['type'] as String),
      text: json['text'] as String?,
      title: json['title'] as String?,
      imageUrl: json['imageUrl'] as String?,
      caption: json['caption'] as String?,
      attribution: json['attribution'] as String?,
    );

Map<String, dynamic> _$ArticleBlockDtoToJson(ArticleBlockDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'text': instance.text,
      'title': instance.title,
      'imageUrl': instance.imageUrl,
      'caption': instance.caption,
      'attribution': instance.attribution,
    };
