// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_block_input_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArticleBlockInputDto _$ArticleBlockInputDtoFromJson(
  Map<String, dynamic> json,
) => ArticleBlockInputDto(
  type: ArticleBlockInputDtoType.fromJson(json['type'] as String),
  text: json['text'] as String?,
  title: json['title'] as String?,
  mediaId: json['mediaId'] as String?,
  caption: json['caption'] as String?,
  attribution: json['attribution'] as String?,
);

Map<String, dynamic> _$ArticleBlockInputDtoToJson(
  ArticleBlockInputDto instance,
) => <String, dynamic>{
  'type': instance.type,
  'text': instance.text,
  'title': instance.title,
  'mediaId': instance.mediaId,
  'caption': instance.caption,
  'attribution': instance.attribution,
};
