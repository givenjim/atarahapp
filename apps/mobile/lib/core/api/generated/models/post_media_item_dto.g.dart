// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_media_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostMediaItemDto _$PostMediaItemDtoFromJson(Map<String, dynamic> json) =>
    PostMediaItemDto(
      id: json['id'] as String,
      kind: PostMediaKind.fromJson(json['kind'] as String),
      url: json['url'] as String?,
      thumbUrl: json['thumbUrl'] as String?,
      width: json['width'] as num?,
      height: json['height'] as num?,
    );

Map<String, dynamic> _$PostMediaItemDtoToJson(PostMediaItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': instance.kind,
      'url': instance.url,
      'thumbUrl': instance.thumbUrl,
      'width': instance.width,
      'height': instance.height,
    };
