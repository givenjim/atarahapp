// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_author_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostAuthorDto _$PostAuthorDtoFromJson(Map<String, dynamic> json) =>
    PostAuthorDto(
      id: json['id'] as String,
      handle: json['handle'] as String?,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      headline: json['headline'] as String?,
      verified: json['verified'] as bool,
    );

Map<String, dynamic> _$PostAuthorDtoToJson(PostAuthorDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'handle': instance.handle,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'headline': instance.headline,
      'verified': instance.verified,
    };
