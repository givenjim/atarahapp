// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'admin_suggestion_dto_status.dart';

part 'admin_suggestion_dto.g.dart';

@JsonSerializable()
class AdminSuggestionDto {
  const AdminSuggestionDto({
    required this.id,
    required this.name,
    required this.disciplineId,
    required this.disciplineName,
    required this.status,
    required this.suggestedById,
    required this.suggestedByName,
    required this.specialisationId,
    required this.resolutionNote,
    required this.resolvedAt,
    required this.createdAt,
  });

  factory AdminSuggestionDto.fromJson(Map<String, Object?> json) =>
      _$AdminSuggestionDtoFromJson(json);

  final String id;
  final String name;
  final String disciplineId;
  final String disciplineName;
  final AdminSuggestionDtoStatus status;
  final String suggestedById;
  final String suggestedByName;
  final String? specialisationId;
  final String? resolutionNote;
  final DateTime? resolvedAt;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$AdminSuggestionDtoToJson(this);
}
