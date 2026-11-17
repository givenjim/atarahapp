// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_viewer_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostViewerDto _$PostViewerDtoFromJson(Map<String, dynamic> json) =>
    PostViewerDto(
      reacted: json['reacted'] as bool,
      saved: json['saved'] as bool,
      muted: json['muted'] as bool,
      isAuthor: json['isAuthor'] as bool,
    );

Map<String, dynamic> _$PostViewerDtoToJson(PostViewerDto instance) =>
    <String, dynamic>{
      'reacted': instance.reacted,
      'saved': instance.saved,
      'muted': instance.muted,
      'isAuthor': instance.isAuthor,
    };
