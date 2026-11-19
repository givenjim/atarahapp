// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'post_group_ref_dto.g.dart';

@JsonSerializable()
class PostGroupRefDto {
  const PostGroupRefDto({
    required this.id,
    required this.slug,
    required this.name,
  });
  
  factory PostGroupRefDto.fromJson(Map<String, Object?> json) => _$PostGroupRefDtoFromJson(json);
  
  final String id;
  final String slug;
  final String name;

  Map<String, Object?> toJson() => _$PostGroupRefDtoToJson(this);
}
