// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'member_hit_dto.g.dart';

@JsonSerializable()
class MemberHitDto {
  const MemberHitDto({
    required this.userId,
    required this.displayName,
    required this.handle,
    this.avatarUrl,
    this.discipline,
  });

  factory MemberHitDto.fromJson(Map<String, Object?> json) =>
      _$MemberHitDtoFromJson(json);

  final String userId;
  final String displayName;
  final String handle;
  final String? avatarUrl;
  final String? discipline;

  Map<String, Object?> toJson() => _$MemberHitDtoToJson(this);
}
