// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post_media_kind.dart';

part 'post_media_item_dto.g.dart';

@JsonSerializable()
class PostMediaItemDto {
  const PostMediaItemDto({
    required this.id,
    required this.kind,
    required this.url,
    required this.thumbUrl,
    required this.width,
    required this.height,
  });

  factory PostMediaItemDto.fromJson(Map<String, Object?> json) =>
      _$PostMediaItemDtoFromJson(json);

  final String id;
  final PostMediaKind kind;

  /// Signed URL; null until processing finished.
  final String? url;

  /// Smaller rendition for lists.
  final String? thumbUrl;
  final num? width;
  final num? height;

  Map<String, Object?> toJson() => _$PostMediaItemDtoToJson(this);
}
