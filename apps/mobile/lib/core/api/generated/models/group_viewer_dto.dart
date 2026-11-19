// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'group_viewer_dto_role.dart';

part 'group_viewer_dto.g.dart';

@JsonSerializable()
class GroupViewerDto {
  const GroupViewerDto({
    required this.joined,
    required this.role,
    required this.canPost,
  });
  
  factory GroupViewerDto.fromJson(Map<String, Object?> json) => _$GroupViewerDtoFromJson(json);
  
  final bool joined;
  final GroupViewerDtoRole? role;

  /// Members can post into the group.
  final bool canPost;

  Map<String, Object?> toJson() => _$GroupViewerDtoToJson(this);
}
