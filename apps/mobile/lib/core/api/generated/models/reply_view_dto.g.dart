// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply_view_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReplyViewDto _$ReplyViewDtoFromJson(Map<String, dynamic> json) => ReplyViewDto(
  id: json['id'] as String,
  postId: json['postId'] as String,
  parentCommentId: json['parentCommentId'] as String,
  body: json['body'] as String,
  author: PostAuthorDto.fromJson(json['author'] as Map<String, dynamic>),
  isMine: json['isMine'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  editedAt: json['editedAt'] == null
      ? null
      : DateTime.parse(json['editedAt'] as String),
);

Map<String, dynamic> _$ReplyViewDtoToJson(ReplyViewDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'postId': instance.postId,
      'parentCommentId': instance.parentCommentId,
      'body': instance.body,
      'author': instance.author,
      'isMine': instance.isMine,
      'createdAt': instance.createdAt.toIso8601String(),
      'editedAt': instance.editedAt?.toIso8601String(),
    };
