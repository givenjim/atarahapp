// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_state_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConnectionStateDto _$ConnectionStateDtoFromJson(Map<String, dynamic> json) =>
    ConnectionStateDto(
      id: json['id'] as String?,
      state: ConnectionStateDtoState.fromJson(json['state'] as String),
      canConnect: json['canConnect'] as bool,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$ConnectionStateDtoToJson(ConnectionStateDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'state': instance.state,
      'canConnect': instance.canConnect,
      'reason': instance.reason,
    };
