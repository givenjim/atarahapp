// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_article_block_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminArticleBlockDto _$AdminArticleBlockDtoFromJson(
  Map<String, dynamic> json,
) => AdminArticleBlockDto(
  type: AdminArticleBlockDtoType.fromJson(json['type'] as String),
  text: json['text'] as String?,
  title: json['title'] as String?,
  imageUrl: json['imageUrl'] as String?,
  caption: json['caption'] as String?,
  attribution: json['attribution'] as String?,
  mediaId: json['mediaId'] as String?,
);

Map<String, dynamic> _$AdminArticleBlockDtoToJson(
  AdminArticleBlockDto instance,
) => <String, dynamic>{
  'type': instance.type,
  'text': instance.text,
  'title': instance.title,
  'imageUrl': instance.imageUrl,
  'caption': instance.caption,
  'attribution': instance.attribution,
  'mediaId': instance.mediaId,
};
