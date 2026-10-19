// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_collaborator_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddCollaboratorDto _$AddCollaboratorDtoFromJson(Map<String, dynamic> json) =>
    AddCollaboratorDto(
      userId: json['userId'] as String?,
      name: json['name'] as String?,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$AddCollaboratorDtoToJson(AddCollaboratorDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'role': instance.role,
    };
