// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'own_counts_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OwnCountsDto _$OwnCountsDtoFromJson(Map<String, dynamic> json) => OwnCountsDto(
  skills: json['skills'] as num,
  connections: json['connections'] as num,
  pendingRequests: json['pendingRequests'] as num,
);

Map<String, dynamic> _$OwnCountsDtoToJson(OwnCountsDto instance) =>
    <String, dynamic>{
      'skills': instance.skills,
      'connections': instance.connections,
      'pendingRequests': instance.pendingRequests,
    };
