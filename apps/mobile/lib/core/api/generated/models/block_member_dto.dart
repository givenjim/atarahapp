// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'block_member_dto.g.dart';

@JsonSerializable()
class BlockMemberDto {
  const BlockMemberDto({this.userId, this.handle});

  factory BlockMemberDto.fromJson(Map<String, Object?> json) =>
      _$BlockMemberDtoFromJson(json);

  final String? userId;

  /// The member’s handle, as an alternative to `userId`.
  final String? handle;

  Map<String, Object?> toJson() => _$BlockMemberDtoToJson(this);
}
