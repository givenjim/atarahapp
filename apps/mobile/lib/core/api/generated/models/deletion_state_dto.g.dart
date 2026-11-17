// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deletion_state_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeletionStateDto _$DeletionStateDtoFromJson(Map<String, dynamic> json) =>
    DeletionStateDto(
      purgeAfter: DateTime.parse(json['purgeAfter'] as String),
      sessionsRevoked: json['sessionsRevoked'] as num,
    );

Map<String, dynamic> _$DeletionStateDtoToJson(DeletionStateDto instance) =>
    <String, dynamic>{
      'purgeAfter': instance.purgeAfter.toIso8601String(),
      'sessionsRevoked': instance.sessionsRevoked,
    };
