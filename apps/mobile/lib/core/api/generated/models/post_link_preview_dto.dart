// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'post_link_preview_dto.g.dart';

@JsonSerializable()
class PostLinkPreviewDto {
  const PostLinkPreviewDto({
    required this.url,
    required this.title,
    required this.description,
    required this.image,
    required this.siteName,
  });

  factory PostLinkPreviewDto.fromJson(Map<String, Object?> json) =>
      _$PostLinkPreviewDtoFromJson(json);

  final String url;
  final String? title;
  final String? description;
  final String? image;
  final String? siteName;

  Map<String, Object?> toJson() => _$PostLinkPreviewDtoToJson(this);
}
