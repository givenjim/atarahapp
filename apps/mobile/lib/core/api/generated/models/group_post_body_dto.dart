// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post_type.dart';

part 'group_post_body_dto.g.dart';

@JsonSerializable()
class GroupPostBodyDto {
  const GroupPostBodyDto({
    required this.type,
    this.body,
    this.mediaIds,
    this.linkUrl,
  });
  
  factory GroupPostBodyDto.fromJson(Map<String, Object?> json) => _$GroupPostBodyDtoFromJson(json);
  
  final PostType type;
  final String? body;
  final List<String>? mediaIds;
  final String? linkUrl;

  Map<String, Object?> toJson() => _$GroupPostBodyDtoToJson(this);
}
