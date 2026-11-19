// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'post_viewer_dto.g.dart';

@JsonSerializable()
class PostViewerDto {
  const PostViewerDto({
    required this.reacted,
    required this.saved,
    required this.muted,
    required this.isAuthor,
  });
  
  factory PostViewerDto.fromJson(Map<String, Object?> json) => _$PostViewerDtoFromJson(json);
  
  final bool reacted;
  final bool saved;

  /// The viewer muted this thread.
  final bool muted;

  /// The viewer wrote it: edit and delete are available.
  final bool isAuthor;

  Map<String, Object?> toJson() => _$PostViewerDtoToJson(this);
}
