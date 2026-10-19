// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'add_collaborator_dto.g.dart';

@JsonSerializable()
class AddCollaboratorDto {
  const AddCollaboratorDto({this.userId, this.name, this.role});

  factory AddCollaboratorDto.fromJson(Map<String, Object?> json) =>
      _$AddCollaboratorDtoFromJson(json);

  /// An Atarah member. They must accept.
  final String? userId;

  /// Someone who is not on Atarah.
  final String? name;
  final String? role;

  Map<String, Object?> toJson() => _$AddCollaboratorDtoToJson(this);
}
