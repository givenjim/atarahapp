// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collaborator_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollaboratorDto _$CollaboratorDtoFromJson(Map<String, dynamic> json) =>
    CollaboratorDto(
      id: json['id'] as String,
      name: json['name'] as String,
      status: CollaboratorDtoStatus.fromJson(json['status'] as String),
      role: json['role'] as String?,
      handle: json['handle'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$CollaboratorDtoToJson(CollaboratorDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'role': instance.role,
      'status': instance.status,
      'handle': instance.handle,
      'avatarUrl': instance.avatarUrl,
    };
