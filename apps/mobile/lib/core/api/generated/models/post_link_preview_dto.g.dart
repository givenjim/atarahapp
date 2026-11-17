// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_link_preview_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostLinkPreviewDto _$PostLinkPreviewDtoFromJson(Map<String, dynamic> json) =>
    PostLinkPreviewDto(
      url: json['url'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      siteName: json['siteName'] as String?,
    );

Map<String, dynamic> _$PostLinkPreviewDtoToJson(PostLinkPreviewDto instance) =>
    <String, dynamic>{
      'url': instance.url,
      'title': instance.title,
      'description': instance.description,
      'image': instance.image,
      'siteName': instance.siteName,
    };
