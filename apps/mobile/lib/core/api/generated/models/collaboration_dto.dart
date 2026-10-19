// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'collaboration_dto_status.dart';

part 'collaboration_dto.g.dart';

@JsonSerializable()
class CollaborationDto {
  const CollaborationDto({
    required this.id,
    required this.status,
    required this.projectId,
    required this.projectTitle,
    required this.ownerName,
    this.role,
    this.ownerHandle,
  });

  factory CollaborationDto.fromJson(Map<String, Object?> json) =>
      _$CollaborationDtoFromJson(json);

  final String id;
  final CollaborationDtoStatus status;
  final String? role;
  final String projectId;
  final String projectTitle;
  final String ownerName;
  final String? ownerHandle;

  Map<String, Object?> toJson() => _$CollaborationDtoToJson(this);
}
