// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'session_view_dto_client.dart';

part 'session_view_dto.g.dart';

@JsonSerializable()
class SessionViewDto {
  const SessionViewDto({
    required this.id,
    required this.client,
    required this.deviceName,
    required this.approxLocation,
    required this.lastActiveAt,
    required this.current,
  });

  factory SessionViewDto.fromJson(Map<String, Object?> json) =>
      _$SessionViewDtoFromJson(json);

  /// Session family id; stable across refresh rotations.
  final String id;
  final SessionViewDtoClient client;
  final String? deviceName;
  final String? approxLocation;
  final DateTime lastActiveAt;
  final bool current;

  Map<String, Object?> toJson() => _$SessionViewDtoToJson(this);
}
