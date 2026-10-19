// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'connection_state_dto_state.dart';

part 'connection_state_dto.g.dart';

@JsonSerializable()
class ConnectionStateDto {
  const ConnectionStateDto({
    required this.id,
    required this.state,
    required this.canConnect,
    this.reason,
  });

  factory ConnectionStateDto.fromJson(Map<String, Object?> json) =>
      _$ConnectionStateDtoFromJson(json);

  final String? id;
  final ConnectionStateDtoState state;

  /// Whether a request can be sent right now.
  final bool canConnect;

  /// Why a request cannot be sent.
  final String? reason;

  Map<String, Object?> toJson() => _$ConnectionStateDtoToJson(this);
}
