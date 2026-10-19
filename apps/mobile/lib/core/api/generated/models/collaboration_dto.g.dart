// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collaboration_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollaborationDto _$CollaborationDtoFromJson(Map<String, dynamic> json) =>
    CollaborationDto(
      id: json['id'] as String,
      status: CollaborationDtoStatus.fromJson(json['status'] as String),
      projectId: json['projectId'] as String,
      projectTitle: json['projectTitle'] as String,
      ownerName: json['ownerName'] as String,
      role: json['role'] as String?,
      ownerHandle: json['ownerHandle'] as String?,
    );

Map<String, dynamic> _$CollaborationDtoToJson(CollaborationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'role': instance.role,
      'projectId': instance.projectId,
      'projectTitle': instance.projectTitle,
      'ownerName': instance.ownerName,
      'ownerHandle': instance.ownerHandle,
    };
