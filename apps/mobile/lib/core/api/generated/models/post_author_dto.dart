// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'post_author_dto.g.dart';

@JsonSerializable()
class PostAuthorDto {
  const PostAuthorDto({
    required this.id,
    required this.handle,
    required this.displayName,
    required this.avatarUrl,
    required this.headline,
    required this.verified,
  });

  factory PostAuthorDto.fromJson(Map<String, Object?> json) =>
      _$PostAuthorDtoFromJson(json);

  final String id;

  /// Null for staff accounts without a profile.
  final String? handle;
  final String displayName;
  final String? avatarUrl;
  final String? headline;

  /// Verified by Atarah.
  final bool verified;

  Map<String, Object?> toJson() => _$PostAuthorDtoToJson(this);
}
