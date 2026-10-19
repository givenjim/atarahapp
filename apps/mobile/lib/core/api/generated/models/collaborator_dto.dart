// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'collaborator_dto_status.dart';

part 'collaborator_dto.g.dart';

@JsonSerializable()
class CollaboratorDto {
  const CollaboratorDto({
    required this.id,
    required this.name,
    required this.status,
    this.role,
    this.handle,
    this.avatarUrl,
  });

  factory CollaboratorDto.fromJson(Map<String, Object?> json) =>
      _$CollaboratorDtoFromJson(json);

  final String id;

  /// A member’s display name, or the name typed in.
  final String name;
  final String? role;
  final CollaboratorDtoStatus status;

  /// Set when the collaborator is a member, so the app can open their profile.
  final String? handle;
  final String? avatarUrl;

  Map<String, Object?> toJson() => _$CollaboratorDtoToJson(this);
}
