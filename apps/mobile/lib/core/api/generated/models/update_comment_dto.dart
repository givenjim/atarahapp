// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'update_comment_dto.g.dart';

@JsonSerializable()
class UpdateCommentDto {
  const UpdateCommentDto({required this.body});

  factory UpdateCommentDto.fromJson(Map<String, Object?> json) =>
      _$UpdateCommentDtoFromJson(json);

  final String body;

  Map<String, Object?> toJson() => _$UpdateCommentDtoToJson(this);
}
