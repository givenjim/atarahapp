// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'post_author_dto.dart';

part 'reply_view_dto.g.dart';

@JsonSerializable()
class ReplyViewDto {
  const ReplyViewDto({
    required this.id,
    required this.postId,
    required this.parentCommentId,
    required this.body,
    required this.author,
    required this.isMine,
    required this.createdAt,
    required this.editedAt,
  });

  factory ReplyViewDto.fromJson(Map<String, Object?> json) =>
      _$ReplyViewDtoFromJson(json);

  final String id;
  final String postId;
  final String parentCommentId;
  final String body;
  final PostAuthorDto author;
  final bool isMine;
  final DateTime createdAt;
  final DateTime? editedAt;

  Map<String, Object?> toJson() => _$ReplyViewDtoToJson(this);
}
