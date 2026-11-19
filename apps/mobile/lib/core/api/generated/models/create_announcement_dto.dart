// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'create_announcement_dto.g.dart';

@JsonSerializable()
class CreateAnnouncementDto {
  const CreateAnnouncementDto({
    required this.body,
    this.groupId,
  });
  
  factory CreateAnnouncementDto.fromJson(Map<String, Object?> json) => _$CreateAnnouncementDtoFromJson(json);
  
  final String body;

  /// Post to one group instead of every member.
  final String? groupId;

  Map<String, Object?> toJson() => _$CreateAnnouncementDtoToJson(this);
}
