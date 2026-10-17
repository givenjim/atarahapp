// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_suggestion_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminSuggestionDto _$AdminSuggestionDtoFromJson(Map<String, dynamic> json) =>
    AdminSuggestionDto(
      id: json['id'] as String,
      name: json['name'] as String,
      disciplineId: json['disciplineId'] as String,
      disciplineName: json['disciplineName'] as String,
      status: AdminSuggestionDtoStatus.fromJson(json['status'] as String),
      suggestedById: json['suggestedById'] as String,
      suggestedByName: json['suggestedByName'] as String,
      specialisationId: json['specialisationId'] as String?,
      resolutionNote: json['resolutionNote'] as String?,
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AdminSuggestionDtoToJson(AdminSuggestionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'disciplineId': instance.disciplineId,
      'disciplineName': instance.disciplineName,
      'status': instance.status,
      'suggestedById': instance.suggestedById,
      'suggestedByName': instance.suggestedByName,
      'specialisationId': instance.specialisationId,
      'resolutionNote': instance.resolutionNote,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
