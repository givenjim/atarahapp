// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_view_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentViewDto _$CommentViewDtoFromJson(Map<String, dynamic> json) =>
    CommentViewDto(
      id: json['id'] as String,
      postId: json['postId'] as String,
      parentCommentId: json['parentCommentId'] as String?,
      body: json['body'] as String,
      author: PostAuthorDto.fromJson(json['author'] as Map<String, dynamic>),
      isMine: json['isMine'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      editedAt: json['editedAt'] == null
          ? null
          : DateTime.parse(json['editedAt'] as String),
      replies: (json['replies'] as List<dynamic>)
          .map((e) => ReplyViewDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CommentViewDtoToJson(CommentViewDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'postId': instance.postId,
      'parentCommentId': instance.parentCommentId,
      'body': instance.body,
      'author': instance.author,
      'isMine': instance.isMine,
      'createdAt': instance.createdAt.toIso8601String(),
      'editedAt': instance.editedAt?.toIso8601String(),
      'replies': instance.replies,
    };
