// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'blocked_member_dto.g.dart';

@JsonSerializable()
class BlockedMemberDto {
  const BlockedMemberDto({
    required this.userId,
    required this.handle,
    required this.displayName,
    required this.avatarUrl,
    required this.blockedAt,
  });
  
  factory BlockedMemberDto.fromJson(Map<String, Object?> json) => _$BlockedMemberDtoFromJson(json);
  
  final String userId;
  final String? handle;
  final String displayName;
  final String? avatarUrl;
  final DateTime blockedAt;

  Map<String, Object?> toJson() => _$BlockedMemberDtoToJson(this);
}
